// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0, parameter int Q = 1) ();
endmodule
module top ();
  sub #(8'h21, 3) u();
endmodule
