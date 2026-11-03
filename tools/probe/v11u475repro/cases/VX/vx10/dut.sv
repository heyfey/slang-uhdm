// § caReduceLeavesOpKept475
// an interface's continuous assignment
interface ifc;
  parameter logic [3:0] A = 4'd3;
  logic [3:0] y;
  assign y = A ^ 4'd1;
endinterface
module top;
  ifc u();
endmodule
