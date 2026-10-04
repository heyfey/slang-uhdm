// § clsTdAnchorAliasQualName235
package p;
class base #(type T=int); endclass
class cb #(type T=int, type CB=int) extends base#(T);
  typedef cb#(T,CB) this_type;
  typedef base#(T) super_type;
  local static this_type m_inst;
endclass
class der #(type T=int, type CB=int) extends cb#(T,CB);
  typedef cb#(T,CB) this_user_type;
  typedef der#(T,CB) this_type;
endclass
typedef cb#(int,byte) cbs_t;
typedef der#(int,byte) ders_t;
typedef der#(bit,byte) ders2_t;
endpackage
package q;
class cb #(type T=int);
  typedef cb#(T) this_type;
  static this_type m_inst;
endclass
typedef cb#(int) qi_t;
endpackage
module top;
endmodule
