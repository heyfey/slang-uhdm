// r10uvm211 arm A — THE MINIMISED CORPUS HEAD.  uvm-1.2's
// `reg/uvm_reg_item.svh:255-313` struct `uvm_reg_bus_op { uvm_access_e kind;
// uvm_reg_addr_t addr; uvm_reg_data_t data; int n_bits; uvm_reg_byte_en_t
// byte_en; uvm_status_e status; }` and `reg/uvm_reg_map.svh:1850`
// `uvm_reg_bus_op accesses[$];` inside the OUT-OF-BODY class method
// `uvm_reg_map::do_bus_write`, WALKED BY `foreach` at `:1924`, and
// wildcard-imported.
//
// THE `foreach` IS THE ARM.  MEASURED with `ct211own --who` on the corpus
// database, the clone declaration's array_typespec is co-owned by exactly ONE
// other declaration, and it is the HOME body's FOREACH REFERENCE VARIABLE:
//
//   WHO[OURS] TOP[2] svaunit_pkg | uvm_reg_map::do_bus_write | d1 | accesses@1850
//     .   array_typespec  n=2
//       <- TOP[1] uvm_pkg | uvm_reg_map | do_bus_write | d4 | accesses@1924
//       <- TOP[2] svaunit_pkg | uvm_reg_map::do_bus_write | d1 | accesses@1850
//
// so an arm WITHOUT the `foreach` gives the clone an unshared array, § 207
// re-points it, and the arm AGREES without ever testing the law (RESUME.md §9:
// an arm agreeing is not an arm testing).
package p211a_a;
  typedef bit [63:0] bt211a;
  typedef struct { bt211a a_addr211; bt211a a_data211; int a_nbits211; } sa211;

  class C211a;
    extern function int do_bus211();
  endclass

  function int C211a::do_bus211();
    sa211 acc211[$];                      // the corpus's `accesses` @1850
    sa211 one211;
    int t211;
    one211.a_addr211 = 64'd1;
    acc211.push_back(one211);
    foreach (acc211[i211])                // the corpus's `accesses` @1924
      t211 = t211 + int'(acc211[i211].a_addr211);
    return t211;
  endfunction
endpackage

package p211b_a;
  import p211a_a::*;
  function automatic int gb211a();
    C211a c211a;
    c211a = new();
    return c211a.do_bus211();
  endfunction
endpackage

module g211_a_head;
  import p211b_a::*;
  int r211a;
  initial r211a = gb211a();
endmodule
