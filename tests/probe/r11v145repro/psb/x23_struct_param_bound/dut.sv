// § psBoundBareRefByBase145
typedef struct packed { int hi; int lo; } b_t;
module dut(input logic [31:0] a, output logic [3:0] o);
  localparam b_t P = '{hi: 5, lo: 2};
  assign o = a[P.hi:P.lo];
endmodule
