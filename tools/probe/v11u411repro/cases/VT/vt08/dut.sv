// § typedCtorClassArgNet411
module top();
  class B; int s = 2; endclass
  class C extends B; function new(); s = 3; endfunction endclass
  class F;
    B o;
    function void mk();
      o = C::new;
    endfunction
  endclass
  F f;
  initial begin f = new; f.mk(); $display(f.o.s); end
endmodule
