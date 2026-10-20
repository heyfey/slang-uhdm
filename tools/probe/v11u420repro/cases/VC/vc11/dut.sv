// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc dif();
  real r = 2.0;
  assign dif.in = r;
endmodule
