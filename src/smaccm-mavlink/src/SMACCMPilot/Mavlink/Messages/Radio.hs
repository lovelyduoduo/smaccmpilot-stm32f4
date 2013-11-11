{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.Radio where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language
import Ivory.Stdlib

radioMsgId :: Uint8
radioMsgId = 166

radioCrcExtra :: Uint8
radioCrcExtra = 21

radioModule :: Module
radioModule = package "mavlink_radio_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkRadioSender
  incl radioUnpack
  defStruct (Proxy :: Proxy "radio_msg")

[ivory|
struct radio_msg
  { rxerrors :: Stored Uint16
  ; fixed :: Stored Uint16
  ; rssi :: Stored Uint8
  ; remrssi :: Stored Uint8
  ; txbuf :: Stored Uint8
  ; noise :: Stored Uint8
  ; remnoise :: Stored Uint8
  }
|]

mkRadioSender ::
  Def ('[ ConstRef s0 (Struct "radio_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkRadioSender =
  proc "mavlink_radio_msg_send"
  $ \msg seqNum sendStruct -> body
  $ do
  arr <- local (iarray [] :: Init (Array 9 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> rxerrors)
  call_ pack buf 2 =<< deref (msg ~> fixed)
  call_ pack buf 4 =<< deref (msg ~> rssi)
  call_ pack buf 5 =<< deref (msg ~> remrssi)
  call_ pack buf 6 =<< deref (msg ~> txbuf)
  call_ pack buf 7 =<< deref (msg ~> noise)
  call_ pack buf 8 =<< deref (msg ~> remnoise)
  -- 6: header len, 2: CRC len
  let usedLen    = 6 + 9 + 2 :: Integer
  let sendArr    = sendStruct ~> mav_array
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "radio payload of length 9 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    radioMsgId
                    radioCrcExtra
                    9
                    seqNum
                    sendStruct

instance MavlinkUnpackableMsg "radio_msg" where
    unpackMsg = ( radioUnpack , radioMsgId )

radioUnpack :: Def ('[ Ref s1 (Struct "radio_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
radioUnpack = proc "mavlink_radio_unpack" $ \ msg buf -> body $ do
  store (msg ~> rxerrors) =<< call unpack buf 0
  store (msg ~> fixed) =<< call unpack buf 2
  store (msg ~> rssi) =<< call unpack buf 4
  store (msg ~> remrssi) =<< call unpack buf 5
  store (msg ~> txbuf) =<< call unpack buf 6
  store (msg ~> noise) =<< call unpack buf 7
  store (msg ~> remnoise) =<< call unpack buf 8

