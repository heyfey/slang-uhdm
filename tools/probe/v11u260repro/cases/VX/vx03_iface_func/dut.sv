// § pkgSelPsBoundColonsElab260 (an interface function, the interface's parameter in the bound)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
interface ifc #(parameter int W = 8);
  logic [W-1:0] q;
  function automatic logic [W-1:0] f(logic [W-1:0] x);
    logic [W-1:0] r;
    r = x;
    r ^= cp::RC[2][W-1:0];
    return r;
  endfunction
endinterface
module top;
  ifc #(.W(4)) i ();
  assign i.q = i.f(4'h3);
endmodule
