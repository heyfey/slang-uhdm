// v201 arm E — an ENUM constant reference and an enum-typed parameter.
package p201ve;
  typedef enum logic [1:0] { VE0 = 2'd0, VE1 = 2'd1 } ve_t;
  parameter       E_A = VE1;
  parameter       E_B = E_A;
  parameter ve_t  E_T = VE1;
  parameter       E_C = E_T;
endpackage
import p201ve::*;
module m201ve;
endmodule
