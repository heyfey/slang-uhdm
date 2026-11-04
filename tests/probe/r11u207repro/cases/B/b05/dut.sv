// § bitSelMethodCallIdxSpan207: this. and super. method calls as indices, a parameterized class, and a generate-scope process reading a handle's method call as an index
package p;
class A #(int N = 4);
  int m_i[int];
  function int gi(int a = 0); return a; endfunction
endclass
class C extends A #(8);
  function int f(C c);
    return m_i[this.gi(1)] + m_i[super.gi(2)] + m_i[c.gi()];
  endfunction
endclass
endpackage
module top(input logic clk, output int o [2]);
  int tbl[8];
  p::C k;
  initial k = new;
  for (genvar g = 0; g < 2; g++) begin : gs
    always_ff @(posedge clk) o[g] <= tbl[k.gi(g)];
  end
endmodule
