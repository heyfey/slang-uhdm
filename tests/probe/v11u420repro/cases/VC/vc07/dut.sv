// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc dif();
  integer c = 9;
  assign dif.in = c;
endmodule
