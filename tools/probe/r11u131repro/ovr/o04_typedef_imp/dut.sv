// § ovrMultiDimConstUnparented131
package pk;
  typedef logic [63:0][5:0] p_t;
  parameter p_t D = '0;
endpackage
module sub;
  import pk::*;
  parameter p_t P = D;
endmodule
module top ();
  sub #(.P(384'b1)) u();
endmodule
