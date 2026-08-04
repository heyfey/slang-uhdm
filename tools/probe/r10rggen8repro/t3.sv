// r10rggen8 t3: compound-assignment statements inside a function body.
// Rggen's rggen_or_reducer:30 `list_index += 1;` comes out of Surelog with a
// UINT:0 Rhs, not UINT:1 — this file puts every compound operator and both a
// literal and an expression Rhs in one function so the rule is legible.
module top #(parameter int N = 3) (output int o);
  function automatic int f(int n);
    int  a;
    int  b;
    a = 0;
    b = 5;
    while (a < n) begin
      a += 1;        // literal 1
      b -= 2;        // literal 2
      b *= 3;        // literal 3
      a += n;        // ref rhs
      b += (n + 1);  // expression rhs
    end
    for (int i = 0; i < n; ++i)
      a += 1;
    a += 1;          // outside any loop
    return a + b;
  endfunction

  localparam int R = f(N);
  assign o = R;
endmodule
