// § forInitSelectLhsBase254 (the struct-member initializer inside a generate block's initial and an always block)
typedef struct { int a; } s_t;
module top #(parameter int P = 1) (output int o [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    s_t s;
    initial begin o[g] = 0; for (s.a = 0; s.a < 4; s.a++) o[g] = o[g] + 1; end
  end
endmodule
