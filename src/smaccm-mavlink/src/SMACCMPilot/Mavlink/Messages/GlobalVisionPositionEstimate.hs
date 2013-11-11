{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.GlobalVisionPositionEstimate where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language
import Ivory.Stdlib

globalVisionPositionEstimateMsgId :: Uint8
globalVisionPositionEstimateMsgId = 101

globalVisionPositionEstimateCrcExtra :: Uint8
globalVisionPositionEstimateCrcExtra = 102

globalVisionPositionEstimateModule :: Module
globalVisionPositionEstimateModule = package "mavlink_global_vision_position_estimate_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkGlobalVisionPositionEstimateSender
  incl globalVisionPositionEstimateUnpack
  defStruct (Proxy :: Proxy "global_vision_position_estimate_msg")

[ivory|
struct global_vision_position_estimate_msg
  { usec :: Stored Uint64
  ; x :: Stored IFloat
  ; y :: Stored IFloat
  ; z :: Stored IFloat
  ; roll :: Stored IFloat
  ; pitch :: Stored IFloat
  ; yaw :: Stored IFloat
  }
|]

mkGlobalVisionPositionEstimateSender ::
  Def ('[ ConstRef s0 (Struct "global_vision_position_estimate_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkGlobalVisionPositionEstimateSender =
  proc "mavlink_global_vision_position_estimate_msg_send"
  $ \msg seqNum sendStruct -> body
  $ do
  arr <- local (iarray [] :: Init (Array 32 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> usec)
  call_ pack buf 8 =<< deref (msg ~> x)
  call_ pack buf 12 =<< deref (msg ~> y)
  call_ pack buf 16 =<< deref (msg ~> z)
  call_ pack buf 20 =<< deref (msg ~> roll)
  call_ pack buf 24 =<< deref (msg ~> pitch)
  call_ pack buf 28 =<< deref (msg ~> yaw)
  -- 6: header len, 2: CRC len
  let usedLen    = 6 + 32 + 2 :: Integer
  let sendArr    = sendStruct ~> mav_array
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "globalVisionPositionEstimate payload of length 32 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    globalVisionPositionEstimateMsgId
                    globalVisionPositionEstimateCrcExtra
                    32
                    seqNum
                    sendStruct

instance MavlinkUnpackableMsg "global_vision_position_estimate_msg" where
    unpackMsg = ( globalVisionPositionEstimateUnpack , globalVisionPositionEstimateMsgId )

globalVisionPositionEstimateUnpack :: Def ('[ Ref s1 (Struct "global_vision_position_estimate_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
globalVisionPositionEstimateUnpack = proc "mavlink_global_vision_position_estimate_unpack" $ \ msg buf -> body $ do
  store (msg ~> usec) =<< call unpack buf 0
  store (msg ~> x) =<< call unpack buf 8
  store (msg ~> y) =<< call unpack buf 12
  store (msg ~> z) =<< call unpack buf 16
  store (msg ~> roll) =<< call unpack buf 20
  store (msg ~> pitch) =<< call unpack buf 24
  store (msg ~> yaw) =<< call unpack buf 28

