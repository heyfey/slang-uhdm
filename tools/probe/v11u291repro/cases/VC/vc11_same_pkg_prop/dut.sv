// § clsSpecDeclNameSpan291
package p;
  class box #(int W = 8); int v; endclass
  class hold;
    box #(8) p;
    function void f();
      box #(2) l;
      l = null;
    endfunction
  endclass
endpackage
module dut; p::hold h; initial h = null; endmodule
