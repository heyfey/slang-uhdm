// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class hold #(int N = 3);
  box #(N) p;
  function void f();
    box #(N+1) l;
    l = null;
  endfunction
endclass
module dut; hold #(5) h; initial h = new; endmodule
