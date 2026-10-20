// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module sub;
  ifc i();
  int c = 3;
  assign i.in = c;
endmodule
module top;
  sub a();
  sub b();
endmodule
