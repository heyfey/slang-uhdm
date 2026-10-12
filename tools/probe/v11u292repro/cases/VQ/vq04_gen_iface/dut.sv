// § pkgVarLvalueScopeSep292
package p; int q; endpackage
interface ifc;
  function automatic void f(); p::q = 6; endfunction
  class k; function void h(); p::q = 8; endfunction endclass
endinterface
module top;
  ifc i();
  for (genvar g = 0; g < 2; g++) begin : gb
    function automatic void gf(); p::q = g; endfunction
    initial p::q = g + 1;
  end
endmodule
