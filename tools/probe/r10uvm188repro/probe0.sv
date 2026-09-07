// r10uvm188 — THE HEAD'S OWN SHAPE, reduced.  uvm_pkg.sv:7856-7935:
//   parameter UVM_FIELD_FLAG_RESERVED_BITS = 28;
//   typedef bit [UVM_FIELD_FLAG_RESERVED_BITS-1 : 0] uvm_field_flag_t;
//   typedef enum uvm_field_flag_t { UVM_DEFAULT_POLICY = 0,
//     UVM_DEEP = (1<<16), UVM_SHALLOW = (1<<17), UVM_REFERENCE = (1<<18) }
//     uvm_recursion_policy_enum;
// Names, numbers and case are all DIFFERENT from the head's so the arm TESTS
// the law rather than agreeing with a memorised string.
package qk0;
  parameter Qk0ReservedBits = 12;
  typedef bit [Qk0ReservedBits-1 : 0] qk0_flag_t;
  typedef enum qk0_flag_t {
    qk0_none  = 0,
    Qk0_Deep  = (1<<5),
    QK0_SHAL  = (1<<6),
    qk0_Ref   = (1<<7)
  } qk0_policy_e;
endpackage
module qm0;
  qk0::qk0_policy_e v0;
  initial v0 = qk0::Qk0_Deep;
endmodule
