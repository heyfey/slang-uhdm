// residue (not written): the importer DEF-view clone binds an LHS indexed part-select to the home variable
package p;
  function automatic void f(int i0);
    logic [15:0] d;
    d[i0*8+:8] = 1;
    d[3:0] = 2;
    d[1] = 1;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
