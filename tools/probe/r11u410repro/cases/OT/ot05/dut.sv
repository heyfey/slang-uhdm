// § oobUnitClsTdUnsupported410
class myclass;
  typedef struct packed { logic a; } s_t;
  typedef enum { A, B } e_t;
  extern function void sub(s_t x, e_t y);
endclass
function void myclass::sub(s_t x, e_t y); endfunction
module test;
endmodule
