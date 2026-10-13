// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut #(parameter int P = 2) (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  localparam int L = 3;
  sub u0 (.a(q.f[P]), .y());
  sub u1 (.a(q.f[L]), .y(y));
endmodule
