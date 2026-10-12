// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
  int qa [0:3];
endpackage
package p;
  class c;
    int y;
    function void h();
      q::qi = 3;
      y = q::qi;
    endfunction
  endclass
endpackage
module top; p::c o = new(); endmodule
