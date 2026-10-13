// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module tgt (output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  assign y = 1'b0;
endmodule
module dut (output logic y);
  tgt t (.y(y));
endmodule
bind tgt sub ub (.a(q.f[i]), .y());
