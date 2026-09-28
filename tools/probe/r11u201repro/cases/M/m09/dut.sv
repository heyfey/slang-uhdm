// § methodArgNestedRefChain201
class C; int q[$]; function int f(int k, int j = 0); return k + j; endfunction endclass
module top;
  C c; int a[4]; int r; int u;
  if (1) begin : g
    int z;
    initial z = c.f(a[r] + 1);
    initial z = c.f(u);
  end
  always @(r) r = c.f(a[r]) + c.f(r + 1);
  initial u = c.f(r, u);
endmodule
