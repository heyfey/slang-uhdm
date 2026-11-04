// § ppMacroBodyLines160
`define ONE(v) v + `__LINE__
module top (output int y, output logic z);
  assign y = `ONE(3); assign z = 1'b1;
endmodule
