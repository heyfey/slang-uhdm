// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0) ();
endmodule
module top ();
  sub #(.P(8'(90))) u();
endmodule
