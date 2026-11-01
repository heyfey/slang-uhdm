// § pkgTdForeignSpecParams460 (class-nested this_type and a class property typed by the alias)
package u;
  class item; endclass
  class S #(type REQ = item);
    typedef S #(REQ) this_type;
    REQ r;
  endclass
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
  class env;
    a_seqr s;
  endclass
endpackage
package t;
  import u::*;
  import a::*;
  typedef a_seqr t_seqr;
  class top_env;
    env e; t_seqr q;
  endclass
endpackage
module top;
  import t::*;
  top_env h;
  initial h = new;
endmodule
