// § methodArgNestedRefChain201
class C;
  function int f(int v, int u); return v + u; endfunction
endclass
module top;
  int a[4];
  int b[2][2];
  for (genvar g = 0; g < 2; g++) begin : gb
    C c;
    int i, r;
    initial begin
      c = new;
      r = c.f(a[i] + g, b[i][g]);
      r = c.f($clog2(a[i]), a[i][3:0]);
    end
  end
endmodule
