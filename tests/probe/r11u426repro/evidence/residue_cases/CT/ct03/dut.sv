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
module top;
  import p::*;
  str_pool x;
endmodule
