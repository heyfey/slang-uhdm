// § ovrMultiDimConstUnparented131
module sub #(parameter logic [7:0] P = 8'h1) ();
endmodule
module top ();
  sub #(.P(8'h5)) u();
endmodule
