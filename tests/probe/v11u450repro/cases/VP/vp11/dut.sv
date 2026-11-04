// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output logic f, output logic [3:0] d);
logic f_q;
always_ff @(posedge clk) f_q <= f;
function void setd(logic [3:0] v);
  d = v;
endfunction
initial f = 0;
endinterface
module top;
  logic clk, ff; logic [3:0] dd;
  bfm u (.clk(clk), .f(ff), .d(dd));
endmodule
