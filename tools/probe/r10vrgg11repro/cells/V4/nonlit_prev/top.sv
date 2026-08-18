module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  for (genvar gi = 0; gi < 3; gi++) begin : g
    localparam int PREV = gi - 1;
    sink #(8) u (.i_value(PREV));
  end
endmodule
