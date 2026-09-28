// § bitSelMethodCallIdxSpan207: an interface function called through an interface port and through an instance as an index, in always blocks and a function
interface bus_if(input logic clk);
  int v;
  function automatic int get(int k = 0); return v + k; endfunction
endinterface
module sub(bus_if b, output int o, output int q);
  int tbl[8];
  always_ff @(posedge b.clk) o <= tbl[b.get()];
  always_comb q = tbl[b.get(1)] + tbl[b.get(.k(2))];
endmodule
module top(input logic clk, output int o, output int q, output int r);
  bus_if bi(clk);
  int tbl[8];
  sub s(bi, o, q);
  always_comb r = tbl[bi.get(3)];
endmodule
