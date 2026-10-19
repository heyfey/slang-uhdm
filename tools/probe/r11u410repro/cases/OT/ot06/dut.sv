// § oobUnitClsTdUnsupported410
class myclass;
  typedef int i_t;
  typedef logic [3:0] n_t;
  typedef bit b_t;
  typedef string s_t;
  extern function void sub(i_t a, n_t b, b_t c, s_t d);
endclass
function void myclass::sub(i_t a, n_t b, b_t c, s_t d); endfunction
module test;
endmodule
