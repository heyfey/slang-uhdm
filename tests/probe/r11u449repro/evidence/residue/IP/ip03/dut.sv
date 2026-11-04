// residue (not written): the importer DEF-view clone binds an LHS indexed part-select to the home variable
package p;
  function automatic int f(input logic [15:0] d, int i0);
    logic [7:0] x;
    x = d[i0*8+:8];
    x[3:0] = d[3:0];
    return x;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
