module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  localparam bit [7:0] MV = 8'hab;
  if (1) begin : g
    sink #(8) u (.i_value(MV));
  end
endmodule
