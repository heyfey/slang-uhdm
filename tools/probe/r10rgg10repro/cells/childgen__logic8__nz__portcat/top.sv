module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module child;
  generate if (1) begin : g
    localparam logic [7:0] IV = 8'hab;
    sink #(8) u_s (.i_value({4'h0,IV[3:0]}));
  end endgenerate
endmodule
module top;
  child u_c();
endmodule
