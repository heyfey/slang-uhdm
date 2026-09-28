// § hpIdxCallNameSpan184: a package-qualified call (r11v184's residue R5 shape) and a class method call as non-trailing indices of rvalue paths, beside a plain call
package pk;
  function automatic int g(input int x); return x & 1; endfunction
endpackage
module top (input int k, output logic [7:0] a, output logic [7:0] b, output logic [7:0] c);
  typedef struct packed { logic [7:0] v; } e_t;
  typedef struct packed { e_t [1:0] w; } m_t;
  m_t m;
  function automatic int f(input int x); return x & 1; endfunction
  always_comb begin
    a = m.w[pk::g(k)].v;
    b = m.w[f(k)].v;
    c = m.w[f(pk::g(k))].v;
  end
endmodule
