// v136 arm A — the declared FACE of a class property (verifier's own grid).
package Pk_Faces;
  typedef struct packed { bit [7:0] loA; bit [7:0] hiB; }        spanBefore_S;
  typedef struct packed { logic [3:0] q4; logic [3:0] r4; }      fourStateW;
  typedef struct packed { bit [3:0] m1; logic [3:0] m2; }        mixedStateZ;
  typedef union  packed { bit [15:0] whole; bit [15:0] alt; }    wrapU16;
  typedef union          { int i9; real f9; }                    loosePick;
  typedef struct         { int deep1; string nm2; }              looseRec;
  typedef enum bit [2:0] { PICK_ZERO, PICK_ONE, PICK_SEVEN = 7 } pick3_e;
  typedef logic [7:0] byteLane_t;
  typedef bit   [7:0] byteBit_t;
  typedef int    tallyInt;
  typedef string labelStr;
  typedef spanBefore_S chain1_S;
  typedef chain1_S     chain2_S;
  typedef struct fwdLater_S;

  class HandleTarget;
    int junk;
  endclass

  class ParamHolder #(parameter int WIDE = 5);
    bit [WIDE-1:0] payload;
  endclass

  class FaceUser;
    spanBefore_S  f01_before;
    fourStateW    f02_fourst;
    mixedStateZ   f03_mixed;
    wrapU16       f04_punion;
    loosePick     f05_uunion;
    looseRec      f06_ustruct;
    pick3_e       f07_enum;
    byteLane_t    f08_logicvec;
    byteBit_t     f09_bitvec;
    tallyInt      f10_int;
    labelStr      f11_str;
    chain2_S      f12_chain2;
    fwdLater_S    f13_fwd;
    HandleTarget  f14_handle;
    ParamHolder#(9) f15_parmcls;
    struct packed { bit [5:0] anonA; bit [1:0] anonB; } f16_anonps;
    struct        { int anonC; int anonD; }             f17_anonus;
    union  packed { bit [7:0] uA; bit [7:0] uB; }       f18_anonpu;
    logic [11:0]  f19_rawvec;
    int           f20_rawint;
  endclass

  typedef struct packed { bit [1:0] lateX; bit [1:0] lateY; } fwdLater_S;
endpackage
