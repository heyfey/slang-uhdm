// § callArgInSelIdxChainName201
typedef struct { int f[4]; } s_t;
module leaf;
  function automatic int fx(int v); return v & 3; endfunction
  s_t s, t;
  int k, r;
  if (1) begin : g
    always @(k) begin
      t.f[fx(s.f[k])] = 1;
      r = t.f[fx(s.f[k])];
    end
  end
endmodule
module top;
  for (genvar j = 0; j < 2; j++) begin : a
    leaf u();
  end
endmodule
