// § queueRetTwinDynShape191: a module function returning a byte queue, a bounded nibble queue, and a class method returning a queue of its type parameter under a default and a specialization
package p;
  class u #(type T = shortint);
    typedef T tq_t[$];
    function tq_t all(); tq_t r; return r; endfunction
  endclass
endpackage
module top;
  typedef byte bq_t[$];
  typedef bit [3:0] nq_t[$:2];
  function automatic bq_t fb(); bq_t r; return r; endfunction
  function automatic nq_t fn(); nq_t r; return r; endfunction
  p::u h0;
  p::u #(logic [2:0]) h1;
endmodule
