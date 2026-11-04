// § ndaSysCallNetTs212 — r11u217 n07: ONE net declaration initialized by `$high` of a port vector (the range-query branch alone)
module dut(input logic [7:2] v, output logic [3:0] o);
  wire [3:0] h = $high(v);
  assign o = h ^ v[5:2];
endmodule
