// § specValueArgRefObj470 (everything at $unit)
class C #(int W = 8, int D = 8);
  int x;
endclass
class K; localparam w = 16; endclass
typedef C #(K::w, 4) cfg_t;
module top; cfg_t h; endmodule
