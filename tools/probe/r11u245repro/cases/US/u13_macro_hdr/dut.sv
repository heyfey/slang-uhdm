// § unitTdLawS245
// $unit typedefs declared through a macro and used inside a macro body
`define TD(T, N) typedef T N;
`TD(int, mi_t)
`TD(logic [5:0], mv_t)
`define DECL(N, V) N V;
module top;
  `DECL(mi_t, a)
  `DECL(mv_t, b)
  function automatic mi_t f(mv_t x); mi_t r; r = x; return r; endfunction
endmodule
