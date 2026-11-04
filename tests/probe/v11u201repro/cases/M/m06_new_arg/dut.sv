// § methodArgNestedRefChain201
class N;
  function int f(int v); return v; endfunction
endclass
class C;
  N c;
  int a[4];
  byte d[];
  task t(int i);
    d = new[c.f(a[i]) + 1];
    d = new[c.f(a[i] + 1)];
  endtask
endclass
module top;
  C x;
  initial begin x = new; x.t(1); end
endmodule
