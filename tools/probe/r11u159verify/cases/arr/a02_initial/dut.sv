// § blockLhsVarSelBindsWholeRef151
module top(output logic o);
  logic [1:0] pa [1:0][1:0];
  logic [1:0] pb [1:0][1:0];
  initial begin
    pa[1][0] = 2'b01;
    pa[0][0] = 2'b10;
    pa[0][1] = 2'b11;
    pa[1][1] = 2'b00;
    pb = pa;
  end
  assign o = pb[0][0][1];
endmodule
