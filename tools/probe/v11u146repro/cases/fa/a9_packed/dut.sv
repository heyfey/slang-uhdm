// § tfArgTypedefLastWriter146
package p;
  typedef enum logic {A, B} e_t;
  function automatic logic g(e_t [1:0] x); return x[0] == B; endfunction
endpackage
module top(output logic o);
  assign o = p::g({p::A, p::B});
endmodule
