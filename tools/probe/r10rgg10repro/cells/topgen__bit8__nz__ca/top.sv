module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  generate if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    wire [7:0] w; assign w = IV;
  end endgenerate
endmodule
