// § clsTdAnchorAliasQualName235
package p;
class cb #(type T=int);
  typedef cb#(T) this_type;
  static this_type m_inst;
endclass
typedef cb#(int) i_t;
typedef cb#(byte) b_t;
endpackage
package q;
class cb #(type T=int);
  typedef cb#(T) this_type;
  static this_type m_inst;
endclass
typedef cb#(longint) l_t;
endpackage
module top;
  q::l_t h;
endmodule
