// § impEnumParamRefNoSize409
package p;
  typedef enum  { A = 0, B, C, D } e_t;
  parameter e_t P = C;
endpackage
import p::*;
module top;
  localparam e_t Q = P;
endmodule
