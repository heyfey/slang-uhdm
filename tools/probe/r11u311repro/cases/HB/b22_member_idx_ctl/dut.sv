// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef struct packed {logic [4:0] x;} ix_t;
  st_t q; ix_t r;
  sub u (.a(q.f[r.x]), .y(y));
endmodule
