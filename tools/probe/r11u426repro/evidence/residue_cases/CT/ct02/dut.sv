// residue (decoded, not written): a class-local typedef of a package-level specialization typedef takes the TOP view of the declaring package as vpiInstance
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
    static function this_type get();
      return null;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  typedef pool #(string) str_pool;
  class C;
    str_pool x;
    function void f(); x = str_pool::get(); endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
