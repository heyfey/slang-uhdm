// § clsScopedBoundPlainClass201v
class G #(int P = 2);
  static const int V = P + 1;
  localparam int LV = 5;
endclass
module top(input logic [15:0] x, output logic [7:0] y, output logic [7:0] y2);
  assign y = x[G#(4)::LV:0];
  assign y2 = x[G#()::LV:1];
endmodule
