// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module sub4 (input logic [3:0] a, output logic y);
  assign y = a[0];
endmodule
module dut(output logic y, output logic y2, output logic y3);
  typedef struct packed {logic [31:0] f; logic [7:0] g;} st_t;
  st_t q; int i; int j;
  sub u (.a(q.f[i]), .y(y));
  sub v (.a(q.g[j]), .y(y2));
  assign y3 = 0;
endmodule
