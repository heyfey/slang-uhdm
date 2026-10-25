// § genBodyBitsOuterNameKeeps429
interface ifc;
  logic [4:0] x;
  logic [7:0] y;
  if (1) begin: g
    always_comb y = $bits(x);
  end
endinterface
module top (output logic [7:0] o);
  ifc u();
  assign o = u.y;
endmodule
