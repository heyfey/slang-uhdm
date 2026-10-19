// § typedCtorClassArgNet411
class B; int s = 2; endclass
class C extends B; function new(); s = 3; endfunction endclass
class F;
  B o;
  function void mk();
    o = C::new;
  endfunction
endclass
module top();
  F f = new;
  initial begin f.mk(); $display(f.o.s); end
endmodule
