// § hcPathIdxBindsDefNet311
module sub (input logic a, output logic y);
  assign y = a;
endmodule
module dut (output logic y);
  logic [31:0] v;
  int i;
  sub u (.a(v[i]), .y(y));
endmodule
