// § dynTdRetTwinNoAlias251 (control: a value parameter sizes the element, no type parameter)
package p;
class c #(int W=4);
  typedef logic [W-1:0] q_t[$];
  function q_t get(); q_t r; return r; endfunction
endclass
endpackage
module top; endmodule
