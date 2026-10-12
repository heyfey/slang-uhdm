// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
module dut;
  function automatic int f();
    box #(4) l;
    l = null;
    return 0;
  endfunction
  int r;
  initial r = f();
endmodule
