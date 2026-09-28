// § hpIdxCallNameSpan184: a class handle's method call as a non-trailing index of an rvalue member path in a class method, and a call inside a part-select bound of the trailing select
package pk;
  typedef struct packed { logic [7:0] v; } e_t;
  typedef struct packed { e_t [3:0] w; } m_t;
  class c;
    m_t m;
    int base;
    function int pick(int x); return x & 3; endfunction
    function logic [7:0] get(c o, int k);
      logic [7:0] r;
      r = m.w[o.pick(k)].v;
      r = r ^ m.w[pick(k)].v;
      return r;
    endfunction
  endclass
endpackage
module top (input int k, output logic [3:0] a);
  typedef struct packed { logic [7:0] v; } e_t;
  typedef struct packed { e_t [3:0] w; } m_t;
  m_t m;
  function automatic int f(input int x); return x & 3; endfunction
  always_comb a = m.w[f(k)].v[f(k) +: 4];
endmodule
