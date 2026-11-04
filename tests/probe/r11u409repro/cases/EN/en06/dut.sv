// § impEnumParamRefNoSize409
package p;
  typedef enum  { A = 5, B, C, D } e_t;
  parameter e_t P = D;
endpackage
import p::*;
module top;

endmodule
