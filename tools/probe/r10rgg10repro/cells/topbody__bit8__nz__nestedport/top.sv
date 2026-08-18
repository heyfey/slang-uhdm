module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  localparam bit [7:0] IV = 8'hab;
  generate
  if (1) begin : n
      sink #(8) u_s (.i_value(IV));
    end
  endgenerate

endmodule
