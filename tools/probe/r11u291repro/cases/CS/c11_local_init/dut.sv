// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class hold;
  function void f();
    box #(8) l = new;
    l = null;
  endfunction
endclass
module dut; hold h; initial h = new; endmodule
