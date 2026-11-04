// § ppMacroBodyLines160
`define A(n) arr_``n;
module top (input logic arr_xyz, output logic y, output logic z);
  assign y = `A(xyz) assign z = arr_xyz;
endmodule
