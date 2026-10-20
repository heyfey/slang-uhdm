// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  wire [7:0] w = 8'd5;
  ifc dif();
  assign dif.in = w;
endmodule
