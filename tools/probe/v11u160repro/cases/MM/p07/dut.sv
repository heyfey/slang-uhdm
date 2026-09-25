// § ppMacroBodyLines160
`define STR(x) `"x`"
module top (output logic [8*6-1:0] y, output logic z);
  assign y = `STR(   abc   ); assign z = 1'b1;
endmodule
