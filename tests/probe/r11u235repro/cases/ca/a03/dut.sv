// § clsTdAnchorAliasQualName235
package p;
class pool #(type K=int, type T=int);
  typedef pool#(K,T) this_type;
  static this_type m_global;
  function this_type get(); return m_global; endfunction
endclass
typedef pool#(string,int) ids_t;
typedef pool#(int,int) ids2_t;
class user;
  typedef pool#(string,string) sp_t;
  sp_t q;
endclass
endpackage
module top;
endmodule
