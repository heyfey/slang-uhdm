module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  if (1) begin : g0
    localparam bit [7:0] IV = 8'hab;
    if (1) begin : g1
      sink #(8) u (.i_value(IV));
    end
  end
endmodule
