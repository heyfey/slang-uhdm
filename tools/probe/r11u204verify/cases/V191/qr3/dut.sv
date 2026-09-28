// § queueRetTwinDynShape191: class methods returning queue typedefs of string, an enum, a class handle, a packed struct and an unpacked struct
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef struct packed { logic [1:0] a; } ps_t;
  typedef struct { int a; } us_t;
  class k; endclass
  class c;
    typedef string sq_t[$];
    typedef e_t eq_t[$];
    typedef k kq_t[$];
    typedef ps_t pq_t[$];
    typedef us_t uq_t[$];
    function sq_t fs(); sq_t r; return r; endfunction
    function eq_t fe(); eq_t r; return r; endfunction
    function kq_t fk(); kq_t r; return r; endfunction
    function pq_t fp(); pq_t r; return r; endfunction
    function uq_t fu(); uq_t r; return r; endfunction
  endclass
endpackage
module top; p::c h; endmodule
