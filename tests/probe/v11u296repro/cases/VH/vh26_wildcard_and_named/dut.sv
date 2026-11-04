// § hcTrailIdxNamesByPortChain296
module sub (input logic a, input int i, output logic y);
  assign y = a;
endmodule
module dut(output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q; int i;
  sub u (.a(q.f[i]), .*);
endmodule
