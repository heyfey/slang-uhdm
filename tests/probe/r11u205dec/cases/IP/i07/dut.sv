// r11u205 IP i07: control, a module-scope target (no generate)
interface bif;
  logic [7:0] d;
endinterface
module dut(input logic [3:0] x, output logic [7:0] o);
  bif b();
  assign b.d[0+:4] = x;
  assign o = b.d;
endmodule
