// § genBodyBitsOuterNameKeeps429
package p;
  logic [6:0] v;
endpackage
module top (output logic [7:0] y);
  if (1) begin: g
    always_comb y = $bits(p::v);
  end
endmodule
