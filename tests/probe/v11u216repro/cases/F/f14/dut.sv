// § ndaSizeQueryFold216 — $size of an unpacked array of structs and of a 2-D unpacked array (declined shapes)
module dut (output logic [7:0] o, output logic [7:0] o2);
  typedef struct packed { logic [1:0] a; } s_t;
  s_t sa [3];
  logic [1:0] m [2][3];
  wire [7:0] w = $size(sa);
  wire [7:0] w2 = $size(m);
  assign o = w;
  assign o2 = w2;
endmodule
