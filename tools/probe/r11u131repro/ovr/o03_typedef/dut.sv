// § ovrMultiDimConstUnparented131
package pk;
  typedef logic [7:0] b_t;
endpackage
module sub #(parameter pk::b_t P = 8'h1) ();
endmodule
module top ();
  sub #(.P(8'h5)) u();
endmodule
