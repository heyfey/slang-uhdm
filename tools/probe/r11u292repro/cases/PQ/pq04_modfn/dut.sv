// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
endpackage
module top;
  int y;
  function automatic void h();
    q::qi = 6;
  endfunction
  initial h();
endmodule
