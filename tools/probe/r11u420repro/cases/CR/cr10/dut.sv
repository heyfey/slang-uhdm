// § contAssignVarInitRhsShared420
module sub;
  logic [7:0] x;
endmodule
module top;
  int cycle = 7;
  sub u();
  assign u.x = cycle;
endmodule
