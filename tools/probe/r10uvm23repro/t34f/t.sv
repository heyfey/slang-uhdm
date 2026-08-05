// t34f — the TYPESPEC-SET question left open by this pass: SeqDriver's five
// adpcm classes read ts=123/124 while uvm_pkg's own listing is 89, and the ~34
// extra entries are all CLASS-LOCAL typedefs (`this_type` / `this_subtype` /
// `type_id` / `super_type`) re-qualified to the IMPORTING package's name.  This
// arm asks the question directly: pk1 holds a class K whose body declares
// `this_type` and `kk_t`; does pk2's class C (and pk2 itself) inherit them?
package pk1;
  typedef bit [3:0] nib_t;
  class K;
    typedef int this_type;
    typedef bit [6:0] kk_t;
    int kv;
  endclass
  int gv1;
endpackage

package pk2;
  import pk1::*;
  class C;
    int m;
  endclass
endpackage

module top;
  pk2::C c;
  initial c = new();
endmodule
