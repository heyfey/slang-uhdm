// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
endpackage
package p;
  function automatic void h();
    q::qi = 4;
  endfunction
  function automatic int g();
    return q::qi;
  endfunction
endpackage
module top; initial p::h(); endmodule
