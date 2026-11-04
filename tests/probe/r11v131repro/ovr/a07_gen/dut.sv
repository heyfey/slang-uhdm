// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0) ();
endmodule
module top ();
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.P(8'h3)) u();
  end
endmodule
