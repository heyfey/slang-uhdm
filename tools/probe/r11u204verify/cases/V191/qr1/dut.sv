// § queueRetTwinDynShape191: package functions returning queues of string, logic [7:0], an enum, a class handle and a packed struct
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef struct packed { logic [1:0] a; } ps_t;
  class k; endclass
  typedef string sq_t[$];
  typedef logic [7:0] lq_t[$];
  typedef e_t eq_t[$];
  typedef k kq_t[$];
  typedef ps_t pq_t[$];
  function automatic sq_t fs(); sq_t r; return r; endfunction
  function automatic lq_t fl(); lq_t r; return r; endfunction
  function automatic eq_t fe(); eq_t r; return r; endfunction
  function automatic kq_t fk(); kq_t r; return r; endfunction
  function automatic pq_t fp(); pq_t r; return r; endfunction
endpackage
module top; endmodule
