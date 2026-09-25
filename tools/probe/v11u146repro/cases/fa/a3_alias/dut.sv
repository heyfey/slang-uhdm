// § tfArgTypedefLastWriter146
package p;
  typedef enum logic {A, B} e_t;
  typedef e_t f_t;
  function automatic logic g(f_t x); return x == B; endfunction
endpackage
module top(output logic o);
  assign o = p::g(p::A);
endmodule
