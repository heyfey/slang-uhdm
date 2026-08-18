// r10vbuvm22 — pathological but LEGAL shapes for the predicate's pointer walks.
package pn;
  class B; int x; endclass
  typedef int ti_t;
  typedef ti_t tq_t[$];
  typedef tq_t tqq_t[$];          // array typedef OF an array typedef, own dims
  typedef tq_t tqa_t;             // alias of an array typedef, NO own dims
  typedef B    bq_t[$];
  typedef bq_t bqq_t[];           // dyn of queue-of-class
  typedef struct { int a; tq_t q; } sr_t;
  typedef sr_t sq_t[$];
  typedef int  m3_t[2][3][4];
  typedef ti_t m3n_t[2][3][4];
  typedef B    m3c_t[2][3][4];
  typedef int  wq_t[*];
  typedef ti_t wqn_t[*];
  function automatic tqq_t f1(); tqq_t r; return r; endfunction
  function automatic tqa_t f2(); tqa_t r; return r; endfunction
  function automatic bqq_t f3(); bqq_t r; return r; endfunction
  function automatic sq_t  f4(); sq_t r;  return r; endfunction
  function automatic m3_t  f5(); m3_t r;  return r; endfunction
  function automatic m3n_t f6(); m3n_t r; return r; endfunction
  function automatic m3c_t f7(); m3c_t r; return r; endfunction
  function automatic wq_t  f8(); wq_t r;  return r; endfunction
  function automatic wqn_t f9(); wqn_t r; return r; endfunction
  class C #(type T = int, int N = 2);
    typedef T   pq_t[$];
    typedef T   pf_t[N];
    typedef T   p2_t[N][N];
    function pq_t g1(); pq_t r; return r; endfunction
    function pf_t g2(); pf_t r; return r; endfunction
    function p2_t g3(); p2_t r; return r; endfunction
  endclass
  class D; typedef D dq_t[$]; function dq_t h(); dq_t r; return r; endfunction endclass
endpackage
module topn;
  import pn::*;
  pn::C #(int, 3) c1;
  pn::C #(pn::B, 2) c2;
  pn::D d1;
  initial begin c1 = new(); c2 = new(); d1 = new(); end
endmodule
