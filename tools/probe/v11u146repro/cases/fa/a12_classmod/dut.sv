// § tfArgTypedefLastWriter146
module top(output logic o);
  typedef enum logic {A, B} e_t;
  class C;
    function logic g(e_t y); return y == B; endfunction
  endclass
  function automatic logic h(e_t z); return z == A; endfunction
  assign o = h(A);
endmodule
