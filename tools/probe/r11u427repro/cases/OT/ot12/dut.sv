// § ovUntypedTsDeclWidth427
interface ifc #(parameter A = 1'b0, parameter B = 'h3)(input logic clk);
  logic [3:0] v;
endinterface
module top(input logic clk, output logic [3:0] o);
  ifc #(.A(4'b1010), .B(12'h123)) i1(clk);
  assign o = i1.v;
endmodule
