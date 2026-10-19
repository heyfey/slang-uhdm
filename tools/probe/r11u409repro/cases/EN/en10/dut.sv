// § impEnumParamRefNoSize409
package p;
  typedef enum  { A = 0, B, C, D } e_t;
  parameter e_t P = C;
endpackage

module top;
  import p::*;
endmodule
