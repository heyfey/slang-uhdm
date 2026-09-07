// v201 arm A — REFERENCE-DEFAULTED copies whose REFERENT carries every
// declared form arm G only tested as a LITERAL default.  The mint's gate is
// on the Lhs clone's typespec, so each of these is a distinct face.
package p201va;
  typedef logic [3:0] vnib_t;
  parameter        A_DEC  = 13;
  parameter [5:0]  A_RNG  = 6'd12;
  parameter signed A_SGN  = 'h5;
  parameter int    A_INT  = 7;
  parameter string A_STR  = "hello";
  parameter vnib_t A_TNIB = 4'h5;
  parameter        A_UDB  = 'd13;
  parameter        A_UNB  = '0;
  // the reference-defaulted copies, UNTYPED Lhs
  parameter R_DEC  = A_DEC;
  parameter R_RNG  = A_RNG;
  parameter R_SGN  = A_SGN;
  parameter R_INT  = A_INT;
  parameter R_STR  = A_STR;
  parameter R_TNIB = A_TNIB;
  parameter R_UDB  = A_UDB;
  parameter R_UNB  = A_UNB;
endpackage
import p201va::*;
module m201va;
endmodule
