// § genIfaceConnGenScopeName313
interface ifc2 (input logic clk, input logic rst);
  logic [7:0] sig;
  modport mp (input sig, input clk, input rst);
endinterface
module child (ifc2.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk ^ p.rst;
endmodule
module top (input logic clk, input logic rst, output logic [1:0] o);
  if (1) begin : g
    ifc2 farr [2] (.clk(clk), .rst(rst));
    child c0 (.p(farr[0]), .o(o[0]));
    child c1 (.p(farr[1]), .o(o[1]));
  end
endmodule
