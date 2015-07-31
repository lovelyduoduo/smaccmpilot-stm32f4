{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PostfixOperators #-}

module SMACCMPilot.Flight.Datalink.CAN.TestProxyODROID
  ( app
  ) where

import Ivory.Language
import Ivory.Stdlib
import Ivory.Tower

import Ivory.Tower.HAL.Bus.CAN.Fragment
import Ivory.Tower.HAL.Bus.Interface

import SMACCMPilot.Flight.Datalink.UART (frameBuffer')
import SMACCMPilot.Flight.Datalink.Commsec
import SMACCMPilot.Flight.Datalink.CAN (s2cType, c2sType)

import SMACCMPilot.Comm.Ivory.Types.SequenceNumberedCameraTarget
import SMACCMPilot.Comm.Ivory.Types.CameraTarget
import SMACCMPilot.Comm.Tower.Interface.ControllableVehicle
import SMACCMPilot.Commsec.Sizes
import SMACCMPilot.Datalink.Mode

import SMACCMPilot.Datalink.HXStream.Tower

import Tower.Odroid.CAN
import Tower.Odroid.UART
import Tower.Odroid.CameraVM

app :: (e -> DatalinkMode)
    -> Maybe (ChanOutput (Struct "camera_angles"))
    -> Tower e ()
app todl anglesRx = do

  (canRx, canTx) <- canTower

  s2c_pt_from_uart <- channel
  s2c_ct_from_uart <- channel
  c2s_from_can     <- channel

  camera_tgt_req   <- channel

  cv_producer      <- controllableVehicleProducerInput (snd c2s_from_can)
  c2s_pt_to_uart   <- controllableVehicleProducerOutput cv_producer
  cv_consumer      <- controllableVehicleConsumerInput (snd s2c_pt_from_uart)
  let cv_consumer' = cv_consumer { cameraTargetInputSetReqConsumer = snd camera_tgt_req
                                 }
  s2c_to_can      <- controllableVehicleConsumerOutput cv_consumer'

  c2s_ct_to_uart  <- channel

  commsecEncodeDatalink todl c2s_pt_to_uart (fst c2s_ct_to_uart)
  commsecDecodeDatalink todl (snd s2c_ct_from_uart) (fst s2c_pt_from_uart)

  uartDatalink (fst s2c_ct_from_uart) (snd c2s_ct_to_uart)

  canDatalink  canTx canRx (fst c2s_from_can) s2c_to_can

  case anglesRx of
    Nothing
      -> return ()
    Just cameraAngles
      -> periodicCamera (fst camera_tgt_req) cameraAngles cv_producer

periodicCamera :: ChanInput (Struct "sequence_numbered_camera_target")
               -> ChanOutput (Struct "camera_angles")
               -> ControllableVehicleProducer
               -> Tower e ()
periodicCamera camera_tgt_reqTx cameraAngles cv_producer = do
  clk             <- period (1000`ms`)
  monitor "periodic_camera_injector" $ do
     angles_st   <- stateInit "angles_st"   izero
     angles_prev <- stateInit "angles_prev" izero
     set_req     <- stateInit "set_req"     izero
     seq_num_g   <- stateInit "seq_num_g"   izero

     handler clk "camera_clk" $ do
       e_set <- emitter camera_tgt_reqTx 1
       callback $ const $ do
         comment ""
         x  <- deref (angles_st ~> angle_x)
         y  <- deref (angles_st ~> angle_y)

         x' <- deref (angles_prev ~> angle_x)
         y' <- deref (angles_prev ~> angle_y)

         unless (x ==? x' .&& y ==? y') $ do
           refCopy angles_prev angles_st
           (set_req ~> seqnum) += 1
--                 snum <- deref (set_req ~> seqnum)
           let ct = set_req ~> val
           store (ct ~> valid)       true
           store (ct ~> angle_right) x
           store (ct ~> angle_up)    y
           emit e_set (constRef set_req)

     handler cameraAngles "anglesRx" $ do
       callback $ \angles -> do
         refCopy angles_st angles

     handler (cameraTargetInputSetRespProducer cv_producer) "set_response" $ do
       callback $ \seqNum -> do
         comment "camera target setting has been acknowledged"
         s <- deref seqNum
         store seq_num_g s

fragmentDrop :: (IvoryArea a, IvoryZero a)
                    => ChanOutput a
                    -> MessageType a
                    -> AbortableTransmit (Struct "can_message") (Stored IBool)
                    -> Tower e ()
fragmentDrop src mt tx = do
  (fragReq, _fragAbort, fragDone) <- fragmentSender mt tx

  monitor "fragment_drop" $ do
    msg          <- state "can_msg"
    in_progress  <- stateInit "in_progress" (ival false)

    handler src "new_msg" $ do
      toFrag <- emitter fragReq 1
      callback $ \ new_msg -> do
        was_in_progress <- deref in_progress
        unless was_in_progress $ do
          refCopy msg new_msg
          emit toFrag (constRef msg)
          store in_progress true

    handler fragDone "fragment_done" $ do
      callback $ const $ store in_progress false

canDatalink :: AbortableTransmit (Struct "can_message") (Stored IBool)
            -> ChanOutput (Struct "can_message")
            -> ChanInput PlaintextArray
            -> ChanOutput PlaintextArray
            -> Tower e ()
canDatalink tx rx assembled toFrag = do
  fragmentReceiver rx [fragmentReceiveHandler assembled s2cType]
  fragmentDrop toFrag c2sType tx

uartDatalink :: ChanInput CyphertextArray
             -> ChanOutput CyphertextArray
             -> Tower e ()
uartDatalink input output = do
  (uarto, uarti) <- uartTower

  input_frames <- channel

  airDataDecodeTower "frame" uarti (fst input_frames)

  frameBuffer' (snd input_frames) (Milliseconds 5) (Proxy :: Proxy 4) input

  airDataEncodeTower "frame" output uarto

