// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  logic [7:0] cyc = 8'd3;
  ifc dif();
  assign dif.in = cyc;
endmodule
