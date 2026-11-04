// § bitSelMethodCallIdxSpan207: method-call indices in a module's initial block, a for-generate always block two levels down and a task, both views
class K;
  int v;
  function int gi(int a); return a + v; endfunction
endclass
module top(input logic clk, output int o [2][2], output int r);
  int tbl[8];
  K k;
  initial begin k = new; r = tbl[k.gi(1)]; end
  task automatic t(output int x); x = tbl[k.gi(2)]; endtask
  for (genvar i = 0; i < 2; i++) begin : g1
    for (genvar j = 0; j < 2; j++) begin : g2
      always_ff @(posedge clk) o[i][j] <= tbl[k.gi(i + j)];
    end
  end
endmodule
