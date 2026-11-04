// § impEnumParamRefNoSize409
package p;
  typedef enum bit [1:0] { A, B, C, D } e_t;
  parameter e_t P = D;
endpackage
import p::*;
module top;
endmodule
