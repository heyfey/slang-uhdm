// r10uvm136 arm Z — THE NEGATIVE CONTROL: a class whose properties cover every
// kind the law must NOT touch (unpacked struct/union, enum, class handle,
// integer atoms, string, chandle, real, plain vectors, arrays, a virtual
// interface).  Not one packed struct or packed union anywhere.  The boundary
// gate must read this arm ELAB-SAME while every packed-struct arm reads
// ELAB-MOVED — otherwise the gate is measuring something other than the law.
interface zif_bus; logic zline; modport IP (input zline); endinterface

package Zctl6;
  typedef struct { int softA; string softB; } zLoose_us;
  typedef union  { int zi; real zr; } zLoose_uu;
  typedef enum bit [1:0] { Z_LO, Z_HI } zPick_e;
  typedef logic [7:0] zByteVec_t;
  typedef bit   [3:0] zNib_t;

  class ZHold99;
    zLoose_us    z01_us;
    zLoose_uu    z02_uu;
    zPick_e      z03_enum;
    zByteVec_t   z04_lv;
    zNib_t       z05_bv;
    int          z06_int;
    byte         z07_byte;
    longint      z08_long;
    integer      z09_integer;
    time         z10_time;
    real         z11_real;
    shortreal    z12_shortreal;
    string       z13_string;
    chandle      z14_chandle;
    ZHold99      z15_handle;
    logic        z16_scalar;
    int          z17_fixed[4];
    string       z18_queue[$];
    int          z19_dyn[];
    int          z20_assoc[string];
    virtual zif_bus.IP z21_vif;
    event        z22_event;
  endclass
endpackage

module ztop;
  Zctl6::ZHold99 z;
  initial z = new();
endmodule
