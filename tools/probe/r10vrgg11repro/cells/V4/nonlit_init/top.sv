module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  for (genvar gi = 0; gi < 2; gi++) begin : g
    localparam bit [7:0] IV = gi + 1;
    sink #(8) u (.i_value(IV));
  end
endmodule
