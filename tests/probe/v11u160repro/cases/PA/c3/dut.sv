// § pasteChainRunning160v
`define A(n) assign arr_``n[1] = 1'b0; assign y = 1'b1;
module top (output logic y);
  logic [1:0] arr_abcd;
  `A(abcd) assign arr_abcd[0] = 1'b1;
endmodule
