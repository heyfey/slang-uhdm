// § unitScalarTdAliasChain410
typedef logic [3:0] n_t;
typedef n_t m_t;
module top (input m_t i, output m_t o);
  m_t x;
  assign x = i;
  assign o = x;
  function automatic m_t f(m_t a); return a; endfunction
endmodule
