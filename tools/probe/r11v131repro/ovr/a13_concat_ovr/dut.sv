// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0) ();
endmodule
module top ();
  sub #(.P({4'h5, 4'ha})) u();
endmodule
