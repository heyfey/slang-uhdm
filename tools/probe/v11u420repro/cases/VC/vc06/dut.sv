// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc dif();
  int c = 8'hff;
  assign dif.in = c;
endmodule
