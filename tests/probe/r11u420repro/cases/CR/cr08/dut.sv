// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top #(parameter P = 4);
  int cycle = P;
  ifc dif();
  assign dif.in = cycle;
endmodule
