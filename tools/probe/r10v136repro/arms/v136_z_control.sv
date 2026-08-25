// v136 arm Z — the NEGATIVE CONTROL: not one packed struct or packed union.
package Pk_Ctl;
  typedef struct { int zsA; string zsB; } looseCtl_S;
  typedef union  { int zuA; real zuB; }   looseCtl_U;
  typedef enum { Z_ONE, Z_TWO } zpick_e;
  typedef logic [9:0] zvec_t;
  typedef int   zint_t;
  typedef string zstr_t;

  class Holder;
    int q1;
  endclass

  class CtlProps;
    looseCtl_S z01_ustruct;
    looseCtl_U z02_uunion;
    zpick_e    z03_enum;
    Holder     z04_handle;
    byte       z05_byte;
    shortint   z06_shortint;
    int        z07_int;
    longint    z08_longint;
    integer    z09_integer;
    time       z10_time;
    real       z11_real;
    shortreal  z12_shortreal;
    string     z13_string;
    chandle    z14_chandle;
    zvec_t     z15_logicvec;
    bit [7:0]  z16_bitvec;
    logic      z17_scalar;
    int        z18_fixed [3];
    int        z19_queue [$];
    int        z20_dyn   [];
    int        z21_assoc [string];
    event      z22_event;
    zint_t     z23_tdint;
    zstr_t     z24_tdstr;
  endclass
endpackage
