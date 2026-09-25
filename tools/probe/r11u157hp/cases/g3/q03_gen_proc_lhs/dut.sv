module top(output logic o);
  if (1) begin : G
    logic x;
  end
  always_comb G.x = 1'b0;
  assign o = G.x;
endmodule
