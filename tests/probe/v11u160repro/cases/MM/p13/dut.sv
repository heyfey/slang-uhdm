// § ppMacroBodyLines160
`define SIG(n) sig_``n
module top (input logic a, output logic y);
  wire `SIG(a) = a; assign y = `SIG(a);
endmodule
