// § ovrMultiDimConstUnparented131
package pk;
  typedef logic [7:0] b_t;
endpackage
module sub;
  import pk::*;
  parameter b_t P = '0;
endmodule
module top ();
  sub #(.P(8'h5)) u();
endmodule
