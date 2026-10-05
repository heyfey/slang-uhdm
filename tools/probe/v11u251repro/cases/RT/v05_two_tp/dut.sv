// § dynTdRetTwinNoAlias251 (the element is the second type parameter, the index the first)
package p;
class c #(type K=int, type V=int);
  typedef V m_t[K];
  function m_t get(); m_t r; return r; endfunction
endclass
endpackage
module top; endmodule
