module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  generate if (1) begin : g
    localparam bit IV = 1'h1;
    sink #(8) u_s (.i_value(IV));
  end endgenerate
endmodule
