// § ovrMultiDimConstUnparented131
module sub #(parameter logic [3:0][5:0] P = '0) ();
endmodule
module top ();
  sub #(.P(24'b1)) u();
endmodule
