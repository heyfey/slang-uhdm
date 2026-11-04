// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  typedef struct packed { logic [2:0] a; logic [3:0] b; } s_t;
  s_t x;
  if (1) begin: g
    always_comb y = $bits(x);
  end
endmodule
