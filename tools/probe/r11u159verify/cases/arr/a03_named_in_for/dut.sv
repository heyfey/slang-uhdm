// § blockLhsVarSelBindsWholeRef151
module top(output logic o);
  logic pa [1:0][1:0];
  logic pb [1:0][1:0];
  always_comb begin
    for (int k = 0; k < 1; k++) begin : blk
      pa[k][0] = 1'b1;
      pa[k][1] = 1'b0;
      pa[1][k] = 1'b1;
      pa[1][1] = 1'b0;
      pb = pa;
    end
    o = pb[0][1];
  end
endmodule
