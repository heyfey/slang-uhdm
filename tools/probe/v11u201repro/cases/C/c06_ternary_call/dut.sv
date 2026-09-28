// § clsScopedBoundWholeSpan201
class K;
  localparam int V = 5;
  static function int f(int a); return a; endfunction
endclass
module top(input logic [15:0] x, output logic [7:0] y, output logic [7:0] y2);
  localparam bit PC = 1;
  assign y = x[(PC ? K::V : 3):0];
  assign y2 = x[K::f(K::V):0];
endmodule
