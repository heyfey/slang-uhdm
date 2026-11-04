// § impEnumParamRefNoSize409
package p;
  typedef enum int { A, B, C } e_t;
  parameter e_t P = C;
endpackage
import p::*;
module top (output [31:0] o);
  assign o = P;
endmodule
