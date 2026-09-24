// § ovrMultiDimConstUnparented131
module sub #(parameter P = 1) ();
endmodule
module top ();
  localparam logic [1:0][3:0] M = 8'h12;
  sub #(.P(M)) u();
endmodule
