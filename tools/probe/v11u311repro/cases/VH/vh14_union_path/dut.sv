// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  typedef union packed {logic [31:0] f; logic [31:0] g;} u_t;
  u_t q;
  int i;
  sub u (.a(q.g[i]), .y(y));
endmodule
