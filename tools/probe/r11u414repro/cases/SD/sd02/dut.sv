// § structMemberDefault414
module top ();
typedef struct {
  int a = 3;
  logic [7:0] b = 8'hAB;
  int c = 1 + 2;
} s_t;
s_t v;
endmodule
