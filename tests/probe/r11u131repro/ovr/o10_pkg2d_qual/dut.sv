// § ovrMultiDimConstUnparented131
package pk;
  typedef logic [3:0][5:0] p_t;
endpackage
module sub #(parameter pk::p_t P = '0) ();
endmodule
module top ();
  sub #(.P(24'b1)) u();
endmodule
