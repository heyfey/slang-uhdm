// § ovrMultiDimConstUnparented131
package pk;
  typedef logic [63:0][5:0] p_t;
endpackage
module sub;
  import pk::*;
  parameter p_t P = '0;
endmodule
module top ();
  sub #(.P(384'b1)) u();
endmodule
