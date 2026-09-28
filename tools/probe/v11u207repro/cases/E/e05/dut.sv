// § parenMethodCallPathSpan207: parenthesized method calls in a module initial block, a for-generate process and as a select index on the left, both views
class K;
  int v;
  function int gi(int a); return a + v; endfunction
endclass
module top(input logic clk, output int o [2], output int r);
  int tbl[8];
  K k;
  initial begin k = new; r = (k.gi(1)); tbl[(k.gi(2))] = 1; end
  for (genvar i = 0; i < 2; i++) begin : g1
    always_ff @(posedge clk) o[i] <= (k.gi(i));
  end
endmodule
