// § ndaSizeFoldReach219 — a two-dimensional array of an unpacked struct and the dimension-argument form $size(m, 2)
module dut (output logic [7:0] o, output logic [7:0] o2);
  typedef struct { logic a; } us_t;
  us_t   su [2][3];
  logic [1:0] m [2][3];
  wire [7:0] w = $size(su);
  wire [7:0] w2 = $size(m, 2);
  assign o = w;
  assign o2 = w2;
endmodule
