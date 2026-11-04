// § ndaSysCallNetTs212 — r11u217 n02: net declarations initialized by the range queries $high, $size, $left, $low, $right of a vector (v11u212 e09 / e16 / g13: golden folds them to a constant)
module dut(input logic [7:2] v, output logic [5:0] o);
  wire [3:0] h = $high(v);
  wire [3:0] s = $size(v);
  wire [3:0] l = $left(v);
  wire [3:0] lo = $low(v);
  wire [3:0] r = $right(v);
  assign o = v ^ {h[1:0], s[1:0], l[0], lo[0] ^ r[0]};
endmodule
