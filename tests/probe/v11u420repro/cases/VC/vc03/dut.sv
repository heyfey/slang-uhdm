// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc dif();
  longint c = 7;
  assign dif.in = c;
endmodule
