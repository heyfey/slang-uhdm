// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
endpackage
interface ifc;
  function void h();
    q::qi = 8;
  endfunction
endinterface
module top; ifc i(); endmodule
