// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0) ();
endmodule
module top ();
  sub u();
  defparam u.P = 8'h5a;
endmodule
