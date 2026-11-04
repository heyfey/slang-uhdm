// § callArgInSelIdxChainName201
typedef struct { logic [7:0] f[4]; } s_t;
module top;
  function automatic int fx(logic [7:0] v); return v & 3; endfunction
  s_t s, t;
  int k;
  logic [15:0] x;
  initial begin
    {>>{t.f[fx(s.f[k])], t.f[0]}} = x;
    x = {<<8{t.f[fx(s.f[k])]}};
  end
endmodule
