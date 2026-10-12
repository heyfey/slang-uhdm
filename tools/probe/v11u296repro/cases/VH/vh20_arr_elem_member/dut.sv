// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut(output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t qa [4];
  int i; int j;
  sub u (.a(qa[i].f[j]), .y(y));
endmodule
