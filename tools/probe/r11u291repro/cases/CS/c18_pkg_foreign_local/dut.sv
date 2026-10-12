// § clsSpecDeclNameSpan291
package q; class box #(int W = 8); int v; endclass endpackage
package p; import q::*;
class hold;
  function void f();
    box #(8) l;
    l = null;
  endfunction
endclass
endpackage
module dut; p::hold h; initial h = null; endmodule
