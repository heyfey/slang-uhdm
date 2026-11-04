// § impEnumParamRefNoSize409
package p;
  typedef enum  { A = 32'd3, B, C, D } e_t;
  parameter e_t P = A;
endpackage
import p::*;
module top;

endmodule
