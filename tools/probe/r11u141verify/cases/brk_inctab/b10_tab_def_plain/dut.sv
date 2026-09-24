// § includeLeadTabIsText130v
// case b10_tab_def_plain: control: TAB before a plain define (text in golden per r11v130 v11)
`include "defs.svh"
`include "body.svh"
module top(input logic [3:0] a, output logic [3:0] y);
  assign y = a + 1;
endmodule
