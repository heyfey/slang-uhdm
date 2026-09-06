// r10v167 arm H - THE DECISIVE PAIR for the arm-G AWAY: a NAMED call that
// SKIPS a middle formal, written CLEAN and written SHELLED, to a
// COMPILATION-UNIT function, a MODULE-LOCAL function, and a $unit function
// whose skipped formal's default is literally 0 - in a generate process and in
// a plain module process.
function automatic int uh167(int a, int b = 91, int c = 92);
  return a + b + c;
endfunction
function automatic int uz167(int a, int b = 0, int c = 0);
  return a + b + c;
endfunction

module mh167 #(parameter int P = 1) (input logic clk, output int o, output int p);
  function int lh167(int a, int b = 91, int c = 92);
    return a + b + c;
  endfunction
  // PLAIN module process (NOT a generate process) - clean cells only
  always_comb p = uh167(.a(1), .c(9));
  generate
    if (P == 1) begin : hlive
      always_comb o = uh167(.a(1), .c(9));
      always_comb o = lh167(.a(1), .c(9));
      always_comb o = uz167(.a(1), .c(9));
    end
    else begin : hdead
      always_comb o = uh167(.a(nosuch167::val), .c(9));
      always_comb o = lh167(.a(nosuch167::val), .c(9));
      always_comb o = uz167(.a(nosuch167::val), .c(9));
    end
  endgenerate
endmodule

module th167 (input logic clk, output int o1, output int p1);
  mh167 #(.P(1)) h1 (.clk(clk), .o(o1), .p(p1));
endmodule
