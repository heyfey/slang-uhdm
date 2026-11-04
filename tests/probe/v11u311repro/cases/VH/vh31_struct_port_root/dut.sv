// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
typedef struct packed {logic [31:0] f;} st_t;
module dut (input st_t q, input int i, output logic y);
  sub u (.a(q.f[i]), .y(y));
endmodule
module top (input st_t q, input int i, output logic y);
  dut d (.q(q), .i(i), .y(y));
endmodule
