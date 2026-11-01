// § ifcTaskFixupWalksWait456
interface bfm(input logic clk, input logic [1:0] sel, output logic [7:0] a);
  logic [7:0] mem [4];
  logic [7:0] w;
  task rd();
    a = mem[sel];
    w[sel] = 1'b1;
    a = w[sel+1];
  endtask
endinterface
module top;
  logic clk;
  logic [1:0] sel;
  logic [7:0] a;
  bfm u(.clk(clk), .sel(sel), .a(a));
endmodule
