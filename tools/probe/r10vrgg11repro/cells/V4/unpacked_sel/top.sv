module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  if (1) begin : g
    localparam bit [7:0] IV [2] = '{8'hab, 8'hcd};
    sink #(8) u (.i_value(IV[0]));
  end
endmodule
