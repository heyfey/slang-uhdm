// § clsScopedBoundWholeSpan201 § classSpecExprArgUnlocated202 § clsScopedBoundPlainClass201v § modSpecValueArgSpanAtName202
class obj; endclass
class K;
  localparam int V = 5;
endclass
class G #(type T = int, int N = 2);
  localparam int V = N + 1;
endclass
module x02 (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  K kh;
  G #(obj, 4) gh;
  G #(int, 3) gi;
  assign y1 = x[K::V:0];
  assign y2 = x[G#(obj, 4)::V:1];
  assign y3 = x[K::V:G#(int, 3)::V];
endmodule
