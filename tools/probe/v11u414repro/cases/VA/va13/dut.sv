// § clsTdArgAliasTwin414
class B;
  typedef int i_t;
endclass
class D extends B;
  function void f(i_t a);
  endfunction
endclass
module top;
  D d;
endmodule
