// § namedUnlinkedWrittenOrder207: a module function called with named arguments, a middle formal skipped and the list reordered, from for-generate and if-generate processes (the definition view's unlinked call)
module top #(parameter P = 1) (input logic clk, input int x, output int o [2], output int q);
  function automatic int f(int a, int b = 1, int c = 2);
    return a * 100 + b * 10 + c;
  endfunction
  for (genvar g = 0; g < 2; g++) begin : gs
    always_ff @(posedge clk) o[g] <= f(.c(3), .a(x));
  end
  if (P) begin : ig
    always_comb q = f(.a(x), .c(g2(.b(1), .a(2))));
  end
  function automatic int g2(int a, int b);
    return a - b;
  endfunction
endmodule
