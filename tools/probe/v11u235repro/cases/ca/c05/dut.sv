// § clsTdAnchorAliasQualName235
package p;
class cb #(type T=int);
  typedef cb#(T) this_type;
  static this_type m_inst;
  static function this_type get(); if (m_inst == null) m_inst = new; return m_inst; endfunction
endclass
typedef cb#(int) i_t;
endpackage
module top;
  p::i_t h;
  initial h = p::i_t::get();
endmodule
