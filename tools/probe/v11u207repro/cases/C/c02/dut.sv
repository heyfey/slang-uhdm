// § namedSlotFillerRootFile207: named calls with unwritten formals in a module instantiated three levels deep, in a generate block and in a continuous assignment
module leaf #(parameter int K = 1) (output int o, output int q);
  function automatic int f(int a, int b = 1, int c = 2); return a + b + c; endfunction
  assign o = f(.b(K), .a(0));
  if (K > 1) begin : gk
    initial q = f(.a(K), .c(K));
  end
endmodule
module mid(output int o [2], output int q [2]);
  leaf #(1) l1(o[0], q[0]);
  leaf #(2) l2(o[1], q[1]);
endmodule
module top(output int o [2], output int q [2]);
  mid m(o, q);
endmodule
