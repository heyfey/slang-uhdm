// § pkgSelPsBoundColonsElab260 (a parameterized class method in a package, the class parameter in the bound)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
package q;
  class C #(int W = 8);
    function logic [15:0] f(logic [15:0] x);
      logic [15:0] r;
      r = x;
      r ^= cp::RC[0][W-1:0];
      return r;
    endfunction
  endclass
endpackage
module top (input logic [15:0] d, output logic [15:0] o);
  assign o = d;
endmodule
