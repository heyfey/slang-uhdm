// § methodArgNestedRefChain201
class N;
  int q[4];
  function int f(int v); return v & 3; endfunction
endclass
class C;
  N c;
  int a[4];
  int i;
  task t();
    a[c.f(a[i])]++;
    this.a[this.c.f(this.a[i] + 1)] = 2;
    c.q[c.f(a[i])] += 1;
  endtask
endclass
module top;
  C x;
  initial begin x = new; x.t(); end
endmodule
