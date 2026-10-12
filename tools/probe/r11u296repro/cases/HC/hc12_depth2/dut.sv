// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module mid (input int j, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t r;
  sub u (.a(r.f[j]), .y(y));
endmodule
module dut(output logic y);
  int i;
  mid m (.j(i), .y(y));
endmodule
