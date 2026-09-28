// law instTypeParamSharesDef120 (residue of this pass, not modelled: a NAMED override by a module-local enum typedef; golden files and spans the instance copy at the typedef)
module test_module #(
  parameter type test_parameter = logic [8:0]
) (
  input test_parameter state_i
);
endmodule
module top();
  typedef enum logic [7:0] {
    FooVariant = 8'b10010101
  } enum_foo_e;
  enum_foo_e foo_inst;
  test_module #(
    .test_parameter(enum_foo_e)
  ) inst1 (
    .state_i(foo_inst)
  );
endmodule
