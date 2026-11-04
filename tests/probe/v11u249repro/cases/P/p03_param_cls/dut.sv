// § clsPropWholeArrTd249
typedef int f_t[3];
class c #(int W = 8);
  f_t m;
  logic [W-1:0] v;
endclass
module top; c #(4) a; c #(16) b; endmodule
