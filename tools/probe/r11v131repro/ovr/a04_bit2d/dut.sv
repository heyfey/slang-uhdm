// § ovrMultiDimConstUnparented131
module sub #(parameter bit [1:0][2:0] P = '0) ();
endmodule
module top ();
  sub #(.P(6'd5)) u();
endmodule
