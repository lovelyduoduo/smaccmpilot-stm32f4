#include <smavlink/pack.h>
#include "smavlink_message_raw_imu.h"
void smavlink_send_raw_imu(struct raw_imu_msg* var0,
                           struct smavlink_out_channel* var1,
                           struct smavlink_system* var2)
{
    uint8_t local0[26U] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0};
    uint8_t(* ref1)[26U] = &local0;
    uint64_t deref2 = *&var0->time_usec;
    
    smavlink_pack_uint64_t(ref1, 0U, deref2);
    
    int16_t deref3 = *&var0->xacc;
    
    smavlink_pack_int16_t(ref1, 8U, deref3);
    
    int16_t deref4 = *&var0->yacc;
    
    smavlink_pack_int16_t(ref1, 10U, deref4);
    
    int16_t deref5 = *&var0->zacc;
    
    smavlink_pack_int16_t(ref1, 12U, deref5);
    
    int16_t deref6 = *&var0->xgyro;
    
    smavlink_pack_int16_t(ref1, 14U, deref6);
    
    int16_t deref7 = *&var0->ygyro;
    
    smavlink_pack_int16_t(ref1, 16U, deref7);
    
    int16_t deref8 = *&var0->zgyro;
    
    smavlink_pack_int16_t(ref1, 18U, deref8);
    
    int16_t deref9 = *&var0->xmag;
    
    smavlink_pack_int16_t(ref1, 20U, deref9);
    
    int16_t deref10 = *&var0->ymag;
    
    smavlink_pack_int16_t(ref1, 22U, deref10);
    
    int16_t deref11 = *&var0->zmag;
    
    smavlink_pack_int16_t(ref1, 24U, deref11);
    smavlink_send_ivory(var1, var2, 27U, ref1, 26U, 144U);
    return;
}