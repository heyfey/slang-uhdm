// residue (decoded, not written): a class-local typedef of a package-level specialization typedef takes the TOP view of the declaring package as vpiInstance
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
    static function this_type get();
      return null;
    endfunction
  endclass
  typedef pool #(string) str_pool;
endpackage
package q;
  import p::*;
  class C;
    str_pool x;
  endclass
endpackage
package r;
  import p::*;
  class D;
    str_pool y;
  endclass
endpackage
module top;
  import q::*;
  import r::*;
  C c;
  D d;
endmodule
