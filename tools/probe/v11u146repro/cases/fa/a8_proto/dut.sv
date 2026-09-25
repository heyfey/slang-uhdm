// § tfArgTypedefLastWriter146
module top(output logic o);
  typedef enum logic {A, B} e_t;
  class C;
    extern function logic f(e_t x);
    function logic g(e_t y); return y == B; endfunction
  endclass
  function logic C::f(e_t x); return x == A; endfunction
  assign o = 1'b0;
endmodule
