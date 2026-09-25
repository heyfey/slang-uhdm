// § lvIdxBitSelAtIndex147
typedef struct packed { logic [3:0] a; logic v; } s_t;
module top (input logic [2:0] b, output s_t s);
  always_comb begin
    s = '0;
    s.a[b[1]] = 1'b1;
  end
endmodule
