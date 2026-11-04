// § bitSelMethodCallIdxSpan207: a module process and a class method in a module, the index call two handles deep and macro-born
`define IDX(h) h.gi(1)
class K;
  int v;
  K nx;
  function int gi(int a); return a + v; endfunction
endclass
module top(input logic clk, output int o, output int q);
  int tbl[8];
  K k;
  initial k = new;
  always_ff @(posedge clk) o <= tbl[k.gi(2)];
  always_comb q = tbl[k.nx.gi(1)] + tbl[`IDX(k)];
endmodule
