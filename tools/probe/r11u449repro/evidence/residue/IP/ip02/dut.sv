// residue (not written): the importer DEF-view clone binds an LHS indexed part-select to the home variable
package p;
  class C;
    extern function void g(int n);
  endclass
  function void C::g(int n);
    bit [63:0] data;
    for (int i0 = 0; i0 < n; i0++)
      data[i0*8+:8] = 8'hff;
    data[7-:4] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
