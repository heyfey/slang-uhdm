// § tdCloneNoPrefixAbstain409v
module top (output [3:0] o);
  typedef bit [3:0] ft_t;
  for (genvar g = 0; g < 2; g++) begin : gb
    localparam ft_t Q = 4'd2 + g;
  end
  assign o = gb[1].Q;
endmodule
