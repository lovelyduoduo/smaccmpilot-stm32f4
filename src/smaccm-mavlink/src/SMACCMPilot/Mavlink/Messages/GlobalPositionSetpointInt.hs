{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.GlobalPositionSetpointInt where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language
import Ivory.Stdlib

globalPositionSetpointIntMsgId :: Uint8
globalPositionSetpointIntMsgId = 52

globalPositionSetpointIntCrcExtra :: Uint8
globalPositionSetpointIntCrcExtra = 141

globalPositionSetpointIntModule :: Module
globalPositionSetpointIntModule = package "mavlink_global_position_setpoint_int_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkGlobalPositionSetpointIntSender
  incl globalPositionSetpointIntUnpack
  defStruct (Proxy :: Proxy "global_position_setpoint_int_msg")

[ivory|
struct global_position_setpoint_int_msg
  { latitude :: Stored Sint32
  ; longitude :: Stored Sint32
  ; altitude :: Stored Sint32
  ; yaw :: Stored Sint16
  ; coordinate_frame :: Stored Uint8
  }
|]

mkGlobalPositionSetpointIntSender ::
  Def ('[ ConstRef s0 (Struct "global_position_setpoint_int_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkGlobalPositionSetpointIntSender =
  proc "mavlink_global_position_setpoint_int_msg_send"
  $ \msg seqNum sendStruct -> body
  $ do
  arr <- local (iarray [] :: Init (Array 15 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> latitude)
  call_ pack buf 4 =<< deref (msg ~> longitude)
  call_ pack buf 8 =<< deref (msg ~> altitude)
  call_ pack buf 12 =<< deref (msg ~> yaw)
  call_ pack buf 14 =<< deref (msg ~> coordinate_frame)
  -- 6: header len, 2: CRC len
  let usedLen    = 6 + 15 + 2 :: Integer
  let sendArr    = sendStruct ~> mav_array
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "globalPositionSetpointInt payload of length 15 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    globalPositionSetpointIntMsgId
                    globalPositionSetpointIntCrcExtra
                    15
                    seqNum
                    sendStruct

instance MavlinkUnpackableMsg "global_position_setpoint_int_msg" where
    unpackMsg = ( globalPositionSetpointIntUnpack , globalPositionSetpointIntMsgId )

globalPositionSetpointIntUnpack :: Def ('[ Ref s1 (Struct "global_position_setpoint_int_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
globalPositionSetpointIntUnpack = proc "mavlink_global_position_setpoint_int_unpack" $ \ msg buf -> body $ do
  store (msg ~> latitude) =<< call unpack buf 0
  store (msg ~> longitude) =<< call unpack buf 4
  store (msg ~> altitude) =<< call unpack buf 8
  store (msg ~> yaw) =<< call unpack buf 12
  store (msg ~> coordinate_frame) =<< call unpack buf 14

