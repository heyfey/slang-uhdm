// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
package p;
class hold;
  box #(8) p;
  function void f();
    box #(4) l;
    l = null;
  endfunction
endclass
endpackage
module dut; p::hold h; initial h = null; endmodule
