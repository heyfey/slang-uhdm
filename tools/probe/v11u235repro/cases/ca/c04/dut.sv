// § clsTdAnchorAliasQualName235
package p;
class cb #(type T=int, int N=2);
  typedef cb#(T,N) this_type;
  static this_type m_inst;
endclass
typedef cb#(int,4) c4_t;
class user;
  typedef cb#(bit,1) u_t;
  u_t h;
endclass
endpackage
module top;
endmodule
