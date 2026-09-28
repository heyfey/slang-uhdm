// § methodArgNestedRefChain201
class N;
  function int f(int v); return v; endfunction
endclass
class B;
  N c;
  int a[4];
endclass
class C extends B;
  int r, i;
  task t();
    r = super.c.f(a[i] + 1);
    r = this.c.f(super.a[i] * 2);
  endtask
endclass
module top;
  C x;
  initial begin x = new; x.t(); end
endmodule
