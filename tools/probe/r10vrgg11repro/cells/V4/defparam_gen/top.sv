module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule

module top;
  if (1) begin : g
    localparam int IV = 4;
    sink u (.i_value(8'h0));
    defparam u.W = IV;
  end
endmodule
