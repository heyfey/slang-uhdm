// § ppMacroBodyLines160
`define A(n) n``_arr[1]
module top (input logic [3:0] xy_arr, output logic y, output logic z);
  assign y = `A(xy); assign z = xy_arr[0];
endmodule
