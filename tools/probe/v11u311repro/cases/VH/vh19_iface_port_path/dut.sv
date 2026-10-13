// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
interface bif;
  logic [31:0] d;
  modport mp (input d);
endinterface
module dut (bif.mp b, output logic y);
  int i;
  sub u (.a(b.d[i]), .y(y));
endmodule
module top (output logic y);
  bif bb ();
  dut d (.b(bb), .y(y));
endmodule
