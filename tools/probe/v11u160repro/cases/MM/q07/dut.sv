// § ppMacroBodyLines160
`define S2(a, b) `"a b`"
module top (output logic [8*8-1:0] y, output logic z);
  assign y = `S2( ab ,  cd ); assign z = 1'b1;
endmodule
