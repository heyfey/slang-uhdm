// § impEnumParamRefNoSize409
package p;
  typedef enum { A, B, C, D } e_t;
  e_t v = A;
  parameter e_t P = C;
  localparam e_t Q = P;
endpackage
module top;
  import p::*;
endmodule
