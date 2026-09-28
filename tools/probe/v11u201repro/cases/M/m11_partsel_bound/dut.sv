// § methodArgNestedRefChain201
class N;
  function int f(int v); return v & 3; endfunction
endclass
module top;
  N c;
  logic [15:0] w;
  int a[4];
  int i;
  logic [3:0] r;
  initial begin
    c = new;
    r = w[c.f(a[i]) +: 4];
    r = w[c.f(a[i] + 1) * 2 +: 4];
  end
endmodule
