// § refFullNameThroughNamedExpr175
class K #(parameter int N = 4);
  int q;
  localparam int L = 2;
  function int f(int a = N, int b = L); return a + b; endfunction
  static function int s(int a = N); return a; endfunction
endclass
module top; K #(5) k; initial begin k = new; void'(k.f()); end endmodule
