// r10uvm114 arm H — the TOP-LEVEL OPERATOR of a packed-dimension bound, in the
// arm-F topology (a second package imports the enum's home package, so the
// module-context enum-base clone is the failing one).  One typedef + one enum
// per operator; the module reads every enum.
`define WIDE114 32

package sorrel114_pkg;
  parameter  int Reach = 12;
  localparam int Lift  = 6;

  typedef bit   [Reach-1:0]      submask_t;    // vpiSubOp
  typedef logic [Reach+1:2]      addmask_t;    // vpiAddOp
  typedef bit   [Reach*2:0]      mulmask_t;    // vpiMultOp
  typedef logic [Reach/2:0]      divmask_t;    // vpiDivOp
  typedef bit   [Reach%7:0]      modmask_t;    // vpiModOp
  typedef logic [Reach<<1:0]     shlmask_t;    // vpiLShiftOp
  typedef bit   [Reach>>1:0]     shrmask_t;    // vpiRShiftOp
  typedef logic [Reach&15:0]     andmask_t;    // vpiBitAndOp
  typedef bit   [Reach|1:0]      ormask_t;     // vpiBitOrOp
  typedef logic [2**Lift:0]      powmask_t;    // vpiPowerOp
  typedef bit   [`WIDE114-1:0]   macmask_t;    // macro literal, vpiSubOp
  typedef logic [Lift+Reach-1:0] summask_t;    // nested, vpiSubOp on top
  typedef bit   [7:0]            flatmask_t;   // literal control, no operator

  typedef enum submask_t  { SUB_ZERO  = 0 } sub_e;
  typedef enum addmask_t  { ADD_ZERO  = 0 } add_e;
  typedef enum mulmask_t  { MUL_ZERO  = 0 } mul_e;
  typedef enum divmask_t  { DIV_ZERO  = 0 } div_e;
  typedef enum modmask_t  { MOD_ZERO  = 0 } mod_e;
  typedef enum shlmask_t  { SHL_ZERO  = 0 } shl_e;
  typedef enum shrmask_t  { SHR_ZERO  = 0 } shr_e;
  typedef enum andmask_t  { AND_ZERO  = 0 } and_e;
  typedef enum ormask_t   { OR_ZERO   = 0 } or_e;
  typedef enum powmask_t  { POW_ZERO  = 0 } pow_e;
  typedef enum macmask_t  { MAC_ZERO  = 0 } mac_e;
  typedef enum summask_t  { SUM_ZERO  = 0 } sum_e;
  typedef enum flatmask_t { FLAT_ZERO = 0 } flat_e;
endpackage

package teasel114_pkg;
  import sorrel114_pkg::*;
  parameter int TeaselDepth = 3;
endpackage

module vetch114_top;
  import sorrel114_pkg::*;
  import teasel114_pkg::*;
  sub_e  s0; add_e  a0; mul_e  m0; div_e  d0; mod_e  o0;
  shl_e  l0; shr_e  r0; and_e  n0; or_e   b0; pow_e  p0;
  mac_e  c0; sum_e  u0; flat_e f0;
  initial begin
    s0 = SUB_ZERO; a0 = ADD_ZERO; m0 = MUL_ZERO; d0 = DIV_ZERO; o0 = MOD_ZERO;
    l0 = SHL_ZERO; r0 = SHR_ZERO; n0 = AND_ZERO; b0 = OR_ZERO;  p0 = POW_ZERO;
    c0 = MAC_ZERO; u0 = SUM_ZERO; f0 = FLAT_ZERO;
  end
endmodule
