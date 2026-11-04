// § blockLhsVarSelBindsWholeRef151
module top(output logic o);
  logic pa [1:0][1:0];
  logic pb [1:0][1:0];
  task automatic t();
    pa[0][0] = 1'b0;
    pa[0][1] = 1'b1;
    pa[1][0] = 1'b1;
    pa[1][1] = 1'b0;
    pb = pa;
  endtask
  always_comb begin
    t();
    o = pb[1][0];
  end
endmodule
