// § ovrMultiDimConstUnparented131
module sub #(parameter P = 1) ();
endmodule
module top ();
  sub #(.P(5)) u();
endmodule
