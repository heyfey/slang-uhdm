// § elabVarSysCallInit412
module top(input logic clk, output logic [31:0] o);
  int cnt = $stime;
  bit [7:0] b = $urandom;
  always_ff @(posedge clk) cnt <= cnt + 1;
  assign o = cnt + b;
endmodule
