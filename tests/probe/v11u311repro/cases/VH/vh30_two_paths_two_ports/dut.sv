// § hcPathIdxBindsDefNet311
module sub2 (input logic a, input logic b, output logic y);
  assign y = a ^ b;
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f; logic [31:0] g;} st_t;
  st_t q;
  int i;
  logic [4:0] j;
  sub2 u (.a(q.f[i]), .b(q.g[j]), .y(y));
endmodule
