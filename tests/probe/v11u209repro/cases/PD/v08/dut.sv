// § ifacePortDeclTsAtPortDecl205: a reg-typed output port redeclared in the body as a variable
interface ifc (clk, o);
  input clk;
  output reg [3:0] o;
  always @(posedge clk) o <= o + 4'd1;
endinterface
module top(input logic clk, output logic [3:0] y);
  ifc i (.clk(clk), .o(y));
endmodule
