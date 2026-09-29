// § incDecOperandKeepsLvalueForm215 — a module struct array's member incremented inside a for-generate always block passed to a function, and an interface function
interface ifc;
  typedef struct { int n; } s_t;
  s_t s;
  function automatic int f(int x); return x; endfunction
  function automatic int bump(); return f(s.n++); endfunction
endinterface
module m(input logic clk, output int o[2]);
  typedef struct { int n; } s_t;
  s_t s[2];
  function automatic int f(int x); return x; endfunction
  ifc u();
  for (genvar gi = 0; gi < 2; gi++) begin : gb
    always @(posedge clk) o[gi] <= f(s[gi].n++);
  end
endmodule
