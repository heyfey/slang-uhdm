// § ppMacroBodyLines160
`define A(n) wire [1:0] arr_``n; assign arr_``n = 2'b01;
module top (output logic [1:0] y);
  `A(abcd) assign y = arr_abcd;
endmodule
