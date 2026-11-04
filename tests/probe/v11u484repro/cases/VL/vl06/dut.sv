// § ownNamedAliasLocalIsRefVar484 (module function in a generate block (abstains))
module top;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  if (1) begin : g
    function int f(int n);
      op2_t a;
      a.k = n;
      return a.k;
    endfunction
  end
  int x;
  initial x = g.f(1);
endmodule
