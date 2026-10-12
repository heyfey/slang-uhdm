// § clsSpecDeclNameSpan291
package p;
class box #(int W = 8); int v; endclass
class hold;
  function void f();
    box #(8) l = new;
    l = null;
  endfunction
endclass
endpackage
module dut; p::hold h; initial h = null; endmodule
