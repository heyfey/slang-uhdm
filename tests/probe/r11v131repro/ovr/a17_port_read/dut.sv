// § ovrMultiDimConstUnparented131
module leaf (input logic [7:0] i);
endmodule
module sub #(parameter logic [1:0][3:0] P = '0) ();
  leaf l(.i(P));
endmodule
module top ();
  sub #(.P(8'h5a)) u();
endmodule
