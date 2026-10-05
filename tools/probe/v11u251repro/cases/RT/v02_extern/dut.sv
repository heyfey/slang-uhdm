// § dynTdRetTwinNoAlias251 (an extern function returning the queue typedef, defined out of body)
package p;
class c #(type T=int);
  typedef T q_t[$];
  extern function q_t get();
endclass
function c::q_t c::get(); q_t r; return r; endfunction
endpackage
module top; endmodule
