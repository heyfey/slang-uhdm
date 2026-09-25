// § ppMacroBodyLines160
`define A(n) arr_``n[1] & 1'b1
module top (input logic [3:0] arr_xyz, output logic y, output logic z);
  assign y = `A(xyz); assign z = arr_xyz[0];
endmodule
