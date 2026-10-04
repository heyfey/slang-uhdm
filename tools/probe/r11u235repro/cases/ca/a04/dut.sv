// § clsTdAnchorAliasQualName235
package p;
class base #(type T=int);
endclass
class cb #(type T=int, type CB=int) extends base#(T);
  typedef base#(T) super_type;
  typedef cb#(T,CB) this_type;
  local static this_type m_inst;
endclass
class der #(type T=int, type ST=int, type CB=int) extends cb#(T,CB);
  typedef der#(T,ST,CB) this_type;
  typedef cb#(T,CB) this_user_type;
  typedef cb#(ST,CB) this_super_type;
endclass
typedef cb#(int,byte) cbs_t;
endpackage
module top;
endmodule
