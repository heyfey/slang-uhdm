// § pkgSelPsBoundColonsElab260 (a class method in a module: a parameter of the module in the bound)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
endpackage
module top #(parameter int W = 8) (input logic [7:0] d, output logic [7:0] q);
  class k;
    function logic [7:0] f(logic [7:0] x);
      logic [7:0] r;
      r = x;
      r ^= cp::RC[0][W-1:0];
      return r;
    endfunction
  endclass
  always_comb q = d;
endmodule
