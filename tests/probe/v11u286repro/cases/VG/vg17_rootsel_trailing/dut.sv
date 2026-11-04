// § genProcLvIdxCallSpan286
module top;
  typedef struct packed { logic [3:0] v; } m_t;
  m_t [1:0] m;
  function automatic int fn(int a); return a; endfunction
  if (1) begin : gi
    always_comb m[1].v[fn(2)] = 1'b1;
  end
endmodule
