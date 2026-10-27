// § progLocalDeclNets444
program prg(input logic clk);
int x;
initial begin
  int q;
  q = x;
end
endprogram
module top;
  logic clk;
  prg p(.clk(clk));
endmodule
