// § tpEnumCopyAtTypedef184 (control): no module-local enum reaches a type parameter (copied from r11u171repro/evidence/residue/T)
module test_module (
  input logic [7:0] state_i
);
endmodule
module top();
  typedef enum logic [7:0] {
    FooVariant = 8'b10010101
  } enum_foo_e;
  enum_foo_e foo_inst;
  test_module inst1 (.state_i(foo_inst));
endmodule
