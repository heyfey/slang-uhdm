module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  generate if (1) begin : g
    localparam int IV = 171;
    sink #(8) u_s (.i_value(IV));
  end endgenerate
endmodule
