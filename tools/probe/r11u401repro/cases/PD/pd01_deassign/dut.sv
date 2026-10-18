// § deassignReleaseObj401
module top(input clk, d, clr, set, output logic q);
always @(clr or set)
  if (clr) assign q = 0;
  else if (set) assign q = 1;
  else deassign q;
always @(posedge clk) q <= d;
endmodule
