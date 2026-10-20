// § implicitPortPaLastIface419
interface ifc #(parameter A = 4, int B = 2) (input clk, output [7:0] o);
  assign o = A + B;
endinterface
module top(input clk, output [7:0] o);
  ifc #(.A(1)) u(clk, o);
endmodule
