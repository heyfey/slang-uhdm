// § methodArgNestedRefChain201
class C;
  function int f(int v); return v; endfunction
  task t(int v); endtask
endclass
module top;
  C c;
  int a[4];
  int i, r;
  initial begin
    c = new;
    c.t(a[i] + 1);
    r = c.f(c.f(a[i]) + 1);
    r = c.f(a[c.f(i)]);
  end
endmodule
