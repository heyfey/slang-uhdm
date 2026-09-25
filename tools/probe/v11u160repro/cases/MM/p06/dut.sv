// § ppMacroBodyLines160
`define ONE(x) wire w_``x; assign w_``x = x;
module top (input logic a, output logic y);
  `ONE(a) assign y = w_a;
endmodule
