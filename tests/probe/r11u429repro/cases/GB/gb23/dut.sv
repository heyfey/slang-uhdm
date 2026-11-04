// § genBodyBitsOuterNameKeeps429
module top (output logic [3:0] y);
  if (1) begin: g
    always_comb begin
      logic [5:0] t;
      t = 0;
      y = $bits(t);
    end
  end
endmodule
