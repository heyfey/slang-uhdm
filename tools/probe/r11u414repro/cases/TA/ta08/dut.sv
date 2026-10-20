// § clsTdArgAliasTwin414
class C #(type T = int);
  typedef T t_t;
  typedef int i_t;
  typedef i_t ii_t;
  function void f(t_t a, ii_t b); endfunction
endclass
module test;
  C #(int) c;
endmodule
