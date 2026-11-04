// § modTdElabFoldSize249 (control: the law does not fire)
module top(input logic clk);
  typedef logic [7:0] f_t[2];
  f_t x;
  always_ff @(posedge clk) x[0] <= x[1];
endmodule
