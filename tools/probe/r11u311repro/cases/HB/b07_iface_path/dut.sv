// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
interface bif;
  typedef struct packed {logic [7:0] f;} s_t;
  s_t s;
endinterface
module dut (output logic y);
  bif bus ();
  int i;
  sub u (.a(bus.s.f[i]), .y(y));
endmodule
