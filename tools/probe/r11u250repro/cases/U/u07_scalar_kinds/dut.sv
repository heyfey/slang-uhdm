// § modParamKwTdCopy250
typedef logic ul_t;
typedef bit signed us_t;
package p;
  typedef logic pl_t;
  typedef time pt_t;
endpackage
module top;
  import p::*;
  parameter ul_t A = 1'b1;
  parameter us_t B = 1'b0;
  parameter pl_t C = 1'b1;
  parameter p::pl_t D = 1'b0;
  parameter pt_t E = 5;
  logic v, w, x, y;
  assign v = A;
  assign w = B;
  assign x = C;
  assign y = D;
endmodule
