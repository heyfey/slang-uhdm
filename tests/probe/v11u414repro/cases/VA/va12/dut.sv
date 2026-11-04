// § clsTdArgAliasTwin414
class C #(int W = 4);
  typedef int i_t;
  function void f(i_t a);
  endfunction
endclass
module top;
  C #(8) c;
endmodule
