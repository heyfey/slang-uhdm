// § dynTdRetTwinNoAlias251 (a derived class returning the base's type-parameter queue typedef)
package p;
class b #(type T=int);
  typedef T q_t[$];
endclass
class d #(type T=int) extends b#(T);
  function q_t get(); q_t r; return r; endfunction
endclass
endpackage
module top; endmodule
