// § ppOutputLine166 (exploratory seed)
`define ONE(a) assign a = 1'b0;
module top(output o, p, q, r);
  assign q = 1'b0; `ONE(o) assign r = 1'b1;
  assign p = 1'b0;
endmodule
