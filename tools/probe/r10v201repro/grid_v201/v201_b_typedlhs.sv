// v201 arm B — the reference-defaulted copy with a TYPED / RANGED / SIGNED /
// TYPEDEF'd LHS.  Arm B of the pass's own grid only varied the REFERENT.
package p201vb;
  typedef logic [3:0] vnib2_t;
  parameter B_BASE = 13;
  parameter int      T_INT  = B_BASE;
  parameter [5:0]    T_RNG  = B_BASE;
  parameter signed   T_SGN  = B_BASE;
  parameter vnib2_t  T_NIB  = B_BASE;
  parameter byte     T_BYTE = B_BASE;
  parameter bit      T_BIT  = 1;
  parameter bit      T_BITR = T_BIT;
endpackage
import p201vb::*;
module m201vb;
endmodule
