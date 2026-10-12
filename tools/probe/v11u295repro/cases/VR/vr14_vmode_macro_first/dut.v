// § rawEndLineModel295
`define ONE 1'b1
module top(o);
  output o;
  logic a = `ONE, c;
  assign o = a;
endmodule
