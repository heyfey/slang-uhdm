// § dynTdRetTwinNoAlias251 (the class specialized and the function called from a module)
package p;
class c #(type T=int);
  typedef T q_t[$];
  static function q_t get(); q_t r; return r; endfunction
endclass
endpackage
module top;
  initial begin
    p::c#(byte)::q_t v;
    v = p::c#(byte)::get();
  end
endmodule
