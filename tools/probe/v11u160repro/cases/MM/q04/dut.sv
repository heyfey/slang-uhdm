// § ppMacroBodyLines160
`define ONE(a, b) assign a = b;
module top (input logic x, input logic w, output logic y, output logic z);
  `ONE(y, (x &
     w)) assign z = x;
endmodule
