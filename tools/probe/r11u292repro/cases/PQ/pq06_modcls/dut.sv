// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
endpackage
module top;
  class c;
    function void h();
      q::qi = 7;
    endfunction
  endclass
  c o = new();
endmodule
