// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
program prg (input logic a);
  initial $display(a);
endprogram
module dut;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  int i;
  prg p (.a(q.f[i]));
endmodule
