// § strLitPpEscIdShift224
module top(input logic [7:0] a, output string o, output logic [7:0] q);
  initial begin
    o = "x\ny` z"; if (a == 8'd3) q = a + 8'd1; else q = 0;
  end
endmodule
