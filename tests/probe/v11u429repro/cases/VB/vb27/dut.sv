// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  typedef enum logic [2:0] {A, B} e_t;
  e_t x;
  byte b;
  if (1) begin: g
    always_comb y = $bits(x) + $bits(b);
  end
endmodule
