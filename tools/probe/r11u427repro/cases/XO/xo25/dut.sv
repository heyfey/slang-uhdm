// § xzOvLitKeepsText427
interface ifc #(parameter P = 1'b0, parameter logic [3:0] Q = 0)(input logic clk);
  logic [3:0] v;
endinterface
module top(input logic clk, output logic [3:0] o);
  ifc #(.P(4'b1x01), .Q(8'hzF)) i1(clk);
  assign o = i1.v;
endmodule
