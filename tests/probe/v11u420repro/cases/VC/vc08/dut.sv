// § contAssignVarInitRhsShared420
interface ifc;
  logic [7:0] in;
endinterface
module top;
  ifc dif();
  shortint c = 2;
  if (1) begin : g
    assign dif.in = c;
  end
endmodule
