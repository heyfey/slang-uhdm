// § ovrMultiDimConstUnparented131
module sub;
  typedef logic [7:0] b_t;
  parameter b_t P = 8'h1;
endmodule
module top ();
  sub #(.P(8'h5)) u();
endmodule
