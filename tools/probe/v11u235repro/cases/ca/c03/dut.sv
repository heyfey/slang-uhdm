// § clsTdAnchorAliasQualName235
package p;
class cb #(type T=int);
  typedef cb#(T) this_type;
  this_type next;
  function this_type get(); return next; endfunction
endclass
endpackage
module top;
  import p::*;
  typedef cb#(int) m_t;
  initial begin m_t x; x = new; end
endmodule
