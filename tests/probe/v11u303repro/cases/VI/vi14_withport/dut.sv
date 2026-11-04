// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 0)(input logic clk);
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? {2{sig}} : '0;
endinterface
module top(input logic clk);
  bus_t2 #(.P(0)) b0(.clk(clk));
  bus_t2 #(.P(0)) b1(clk);
endmodule
