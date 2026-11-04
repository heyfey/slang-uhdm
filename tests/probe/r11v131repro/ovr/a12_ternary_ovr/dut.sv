// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0) ();
endmodule
module top ();
  parameter int W = 1;
  sub #(.P(W > 0 ? 8'h5a : 8'h00)) u();
endmodule
