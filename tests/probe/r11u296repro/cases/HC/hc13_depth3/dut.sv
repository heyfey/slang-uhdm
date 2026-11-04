// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module mid2 (input int j, output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t r;
  sub u (.a(r.f[j - 1]), .y(y));
endmodule
module mid1 (input int j, output logic y);
  mid2 m2 (.j(j), .y(y));
endmodule
module dut(output logic y);
  int i;
  mid1 m1 (.j(i), .y(y));
endmodule
