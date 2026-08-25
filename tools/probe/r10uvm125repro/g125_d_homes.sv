// r10uvm125 arm D — the same converting output actual in every HOME:
// module task, module function, initial block, always block, generate block,
// package function, class method — and THREE module instances.
package pk125d;
  typedef bit [63:0] wide_t;
  function automatic int gfun(input int p, output wide_t v);
    v = 64'd9; return p;
  endfunction
endpackage

module sub125 #(parameter int W = 8) (input logic clk);
  import pk125d::*;
  bit [W-1:0] q;
  int         r;

  task automatic tk();
    r = gfun(1, q);
  endtask

  function automatic int fn();
    r = gfun(2, q);
    return r;
  endfunction

  initial begin
    r = gfun(3, q);
  end

  always @(posedge clk) begin
    r = gfun(4, q);
  end

  if (W > 4) begin : gblk
    int gr;
    bit [15:0] gq;
    initial gr = gfun(5, gq);
  end
endmodule

module top125;
  logic clk;
  sub125 #(8)  i0 (.clk(clk));
  sub125 #(16) i1 (.clk(clk));
  sub125 #(32) i2 (.clk(clk));
endmodule
