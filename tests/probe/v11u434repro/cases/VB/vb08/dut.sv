// § genBodyDefBitsKeepsCall434
interface ifc #(parameter W = 2);
  logic [4:0] x;
  logic [31:0] y;
  if (W > 1) begin : g
    assign y = $bits(x);
  end
endinterface
module top;
  ifc u();
endmodule
