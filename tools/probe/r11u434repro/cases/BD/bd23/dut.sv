// § genBodyDefBitsKeepsCall434
interface ifc;
  logic [4:0] x;
  logic [31:0] y;
  if (1) begin: g
    assign y = $bits(x);
  end
endinterface
module top;
  ifc i();
endmodule
