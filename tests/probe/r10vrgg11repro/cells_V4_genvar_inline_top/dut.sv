module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  for (genvar gi = 0; gi < 2; gi++) begin : g
    sink #(8) u (.i_value(gi));
  end
endmodule
