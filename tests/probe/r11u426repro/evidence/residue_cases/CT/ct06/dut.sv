// residue (decoded, not written): a class-local typedef of a package-level specialization typedef takes the TOP view of the declaring package as vpiInstance
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
  endclass
  typedef pool #(string) str_pool;
endpackage
package q;
  import p::*;
  class C;
    int k;
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
