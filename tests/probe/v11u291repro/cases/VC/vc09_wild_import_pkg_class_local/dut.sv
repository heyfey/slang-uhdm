// § clsSpecDeclNameSpan291
package q; class box #(int W = 8); int v; endclass endpackage
module dut;
  import q::*;
  class hold;
    box #(8) p;
    function void f();
      box #(2) l;
      l = null;
    endfunction
  endclass
  hold h;
  initial h = new;
endmodule
