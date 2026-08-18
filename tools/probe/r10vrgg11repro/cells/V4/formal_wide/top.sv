module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(32) u (.i_value(IV));
    sink #(4)  v (.i_value(IV[3:0]));
  end
endmodule
