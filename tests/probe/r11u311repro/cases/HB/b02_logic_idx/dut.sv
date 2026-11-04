// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  logic [4:0] k;
  sub u (.a(q.f[k]), .y(y));
endmodule
