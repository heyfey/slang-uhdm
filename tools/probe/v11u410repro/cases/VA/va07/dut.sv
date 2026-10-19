// § unitScalarTdAliasChain410
typedef logic l1_t;
typedef l1_t l2_t;
typedef logic [3:0] n_t;
typedef n_t m_t;
function automatic m_t f(l2_t a); return {4{a}}; endfunction
class K; m_t k; l2_t j; endclass
module top (input l2_t i, output m_t o);
  assign o = f(i);
  K kk = new;
endmodule
