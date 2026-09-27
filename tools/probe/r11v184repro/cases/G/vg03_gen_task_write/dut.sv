// § genScopeTrailSelNameLate184: a generate block's task writing a trailing member select, called from an initial block
typedef struct packed { logic [7:0] f; } s_t;
module top #(parameter bit P = 1) (input int i);
  s_t t;
  if (P) begin : gb
    task automatic wr(int k); t.f[k] = 1'b1; endtask
    initial wr(i);
  end
endmodule
