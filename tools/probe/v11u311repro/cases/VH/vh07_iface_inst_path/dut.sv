// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
interface bif;
  logic [31:0] d;
endinterface
module dut (output logic y);
  bif bi ();
  int i;
  sub u (.a(bi.d[i]), .y(y));
endmodule
