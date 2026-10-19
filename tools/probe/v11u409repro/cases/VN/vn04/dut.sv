// § impEnumParamRefNoSize409
package p;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
  parameter f_t P = C;
endpackage
import p::*;
module top (output [31:0] o);
  assign o = P;
endmodule
