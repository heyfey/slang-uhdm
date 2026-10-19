// § impEnumParamRefNoSize409
package p;
  typedef enum logic [3:0] { A = 0, B, C, D } e_t;
  parameter e_t P = C;
endpackage
import p::*;
module top;

endmodule
