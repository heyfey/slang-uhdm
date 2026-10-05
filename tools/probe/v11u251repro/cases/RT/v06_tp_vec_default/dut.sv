// § dynTdRetTwinNoAlias251 (a type-parameter default that is a packed vector; queue and dynamic typedefs)
package p;
class c #(type T=logic [3:0]);
  typedef T q_t[$];
  typedef T d_t[];
  function q_t gq(); q_t r; return r; endfunction
  function d_t gd(); d_t r; return r; endfunction
endclass
endpackage
module top; endmodule
