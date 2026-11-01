// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, output logic [7:0] a);
  int i;
  logic [7:0] m [4][2];
  task fill();
    foreach (m[i, j]) begin
      m[i][j] = a + i;
    end
    i = 3;
  endtask
endinterface
module top;
  logic clk;
  logic [7:0] a;
  bfm u(.clk(clk), .a(a));
endmodule
