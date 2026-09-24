// § ovrMultiDimConstUnparented131
module sub;
  typedef logic [3:0][5:0] p_t;
  parameter p_t P = 24'h3;
endmodule
module top ();
  sub u();
endmodule
