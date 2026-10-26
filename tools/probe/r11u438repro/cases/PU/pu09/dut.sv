// § caPlainLhsUnsizedClone438 (interface twin control)
interface ifc(input [15:0] b);
  logic y;
  assign y = b['hA];
endinterface
module top(input [15:0] b, output y);
  ifc i(.b(b));
  assign y = i.y;
endmodule
