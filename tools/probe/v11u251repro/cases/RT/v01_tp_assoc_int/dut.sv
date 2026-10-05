// § dynTdRetTwinNoAlias251 (a type-parameter element associative typedef indexed by int, returned)
package p;
class c #(type T=int);
  typedef T a_t[int];
  function a_t get(); a_t r; return r; endfunction
endclass
endpackage
module top; endmodule
