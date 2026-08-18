module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u [0:1] (.i_value(IV));
  end
endmodule
