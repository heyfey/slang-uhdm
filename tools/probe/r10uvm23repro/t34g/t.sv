// t34g — the same TYPESPEC-SET question with the one ingredient t34f lacked:
// a PARAMETERIZED class in the imported package, SPECIALIZED by the importing
// package.  UVM's `this_type` / `type_id` extras are all class-local typedefs
// of parameterized uvm classes, so if specialization is what publishes them
// into the importing scope's DataTypeMap this arm shows it: golden's `pk2::C`
// (and pk2 itself) would list `kk_t` / `this_type` re-qualified `pk2::...`.
package pk1;
  typedef bit [3:0] nib_t;
  class K #(type T = int);
    typedef K #(T) this_type;
    typedef bit [6:0] kk_t;
    T kv;
  endclass
  int gv1;
endpackage

package pk2;
  import pk1::*;
  class C;
    K #(byte) kb;
    int m;
  endclass
endpackage

module top;
  pk2::C c;
  initial c = new();
endmodule
