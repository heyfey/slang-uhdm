// § ifArrElemLitCaFresh225 — fresh: a struct member of an interface-array element (two dots after the select)
interface bi;
  typedef struct packed { logic f; logic [2:0] g; } s_t;
  s_t s;
endinterface
module dut(output logic o, output logic [2:0] q);
  localparam int K = 0;
  bi b[2]();
  assign b[K].s.f = 1'b1;
  assign b[1].s.g = 3'd5;
  assign o = b[K].s.f;
  assign q = b[1].s.g;
endmodule
