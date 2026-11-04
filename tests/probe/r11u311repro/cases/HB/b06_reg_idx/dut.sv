// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  reg [3:0] r;
  wire [3:0] w;
  sub u0 (.a(q.f[r]), .y());
  sub u1 (.a(q.f[w]), .y(y));
endmodule
