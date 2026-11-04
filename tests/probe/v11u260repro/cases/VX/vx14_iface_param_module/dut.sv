// § pkgSelPsBoundColonsElab260 (an interface's parameter, its always_comb)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
interface ifc #(parameter int W = 8) (input logic [15:0] d);
  logic [15:0] q;
  always_comb q = cp::RC[1][W-1:0];
endinterface
module top;
  logic [15:0] d;
  ifc #(.W(6)) i (.d(d));
endmodule
