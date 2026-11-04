// § modArrConcatInitElemSize430
module top(input clk, output logic [31:0] o);
  int tab[4] = { 10, 20, 30, 40 };
  always_ff @(posedge clk) o <= tab[1];
endmodule
