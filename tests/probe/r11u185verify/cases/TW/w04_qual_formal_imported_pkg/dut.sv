// § tfArgQualOutsideWriter176 § tfArgClassMethodOrder176
package pa;
  typedef enum logic [2:0] {X0, X1, X2} e_t;
  typedef struct packed { logic [3:0] d; } s_t;
endpackage
package pb;
  import pa::*;
  class k;
    function void m(pa::e_t v, pa::s_t w); endfunction
  endclass
endpackage
module top;
  import pb::*;
  function automatic int g(pa::e_t v);
    return int'(v);
  endfunction
  k o; int r;
  initial begin o = new; o.m(pa::X1, '0); r = g(pa::X2); end
endmodule
