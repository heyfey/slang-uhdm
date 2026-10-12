// § clsSpecDeclNameSpan291
package q; class box #(int W = 8); int v; endclass endpackage
package p; import q::*;
  function automatic int f();
    box #(4) l;
    l = null;
    return 0;
  endfunction
endpackage
module dut; int r; initial r = p::f(); endmodule
