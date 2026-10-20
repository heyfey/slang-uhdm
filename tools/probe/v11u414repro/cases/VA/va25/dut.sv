// § clsTdArgAliasTwin414
class B;
  typedef int i_t;
endclass
class D extends B;
  typedef int j_t;
  function void f(i_t a, j_t b);
  endfunction
endclass
module top;
  D d;
endmodule
