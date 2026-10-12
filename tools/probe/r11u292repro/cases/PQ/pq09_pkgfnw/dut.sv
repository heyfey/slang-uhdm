// § pkgVarLvalueScopeSep292
package q;
  int qi = 3;
  logic [7:0] qv;
endpackage
package p;
  function automatic void h();
    q::qi = 4;
    q::qv[2] = 1'b0;
  endfunction
endpackage
module top; initial p::h(); endmodule
