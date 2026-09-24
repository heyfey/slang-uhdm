// § ovrMultiDimConstUnparented131
module sub;
  typedef logic [3:0][5:0] p_t;
  parameter p_t P = '0;
endmodule
module top ();
  sub #(.P(24'b1)) u();
endmodule
