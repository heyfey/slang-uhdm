// § ppMacroBodyLines160
`define STR(x) `"x`"
module top (output logic [8*8-1:0] y, output logic z);
  initial $display(`STR(a "q" b)); assign z = 1'b1;
  assign y = 0;
endmodule
