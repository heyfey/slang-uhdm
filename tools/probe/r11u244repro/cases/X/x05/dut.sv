// § lvHpIpsOperandChain244
typedef struct packed { logic [3:0] k; } ix_t;
typedef struct packed { logic [63:0] d; } st_t;
module top(input ix_t t, output st_t s, output st_t s2);
  always_comb begin
    s = '0;
    for (int i = 0; i < 4; i++) s.d[i*8 +: 8] = 8'(t.k);
    s.d[t.k*2 +: 2] = 2'b1;
  end
  always_comb begin
    s2 = '0;
    s2.d[(t.k+1)*4-1 -: 4] = 4'hf;
  end
endmodule
