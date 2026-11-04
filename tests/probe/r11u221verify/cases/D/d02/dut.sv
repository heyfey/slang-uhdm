// § incDecOperandKeepsLvalueForm215 — prefix and postfix inc/dec of nested struct members and class-handle members in a module's initial, always block and function
module dut (input logic clk, output int o);
  typedef struct { int c; } in_t;
  typedef struct { in_t b; int n; } out_t;
  class cnt; int v; in_t s; endclass
  out_t a;
  cnt h;
  int arr [4];
  function automatic int f(int x); return x; endfunction
  initial begin
    h = new;
    a.b.c++;
    --a.n;
    o = f(h.v++) + f(++h.s.c);
  end
  always @(posedge clk) begin
    arr[a.n--] <= f(a.b.c--);
  end
endmodule
