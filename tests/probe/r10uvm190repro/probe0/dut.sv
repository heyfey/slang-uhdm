// r10uvm190 — the head's own shape, in twenty lines.
//
// BuildUVMPkg, `1800.2-2017-1.0/pp_output/uvm_pkg.sv`:
//   7856  parameter UVM_FIELD_FLAG_RESERVED_BITS = 28;
//   7859  typedef bit [UVM_FIELD_FLAG_RESERVED_BITS-1 : 0] uvm_field_flag_t;
//   7880  typedef enum uvm_field_flag_t { ... } uvm_radix_enum;
//
// golden gives the ENUM BASE a per-declaration `clone_tree` copy of the
// typedef's typespec whose OWN packed-range reference is BARE, while the
// package's listing object binds the very same reference to the parameter's
// `param_assign` Rhs constant.  We shared ONE range subtree across both, so our
// clone inherited the binding.
package pk190;
  parameter RES_BITS = 28;
  typedef bit [RES_BITS-1 : 0] flag_t;
  typedef enum flag_t { A0 = 0, A1 = 1 } radix_e;
  typedef enum flag_t { B0 = 0, B1 = 2 } policy_e;
  flag_t  w;
  radix_e r;
  policy_e p;
endpackage

module probe0;
  pk190::radix_e  q;
  pk190::policy_e s;
  initial begin q = pk190::A1; s = pk190::B1; end
endmodule
