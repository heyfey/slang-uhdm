// r10earl118 arm a1_bind118 -- WHEN DOES SURELOG BIND A GENERATE-SCOPE
// CONTINUOUS ASSIGN'S WHOLE-NAME TARGET REFERENCE?
//
// MEASUREMENT ONLY.  Every row is legal SystemVerilog and every row is scored
// against the GOLDEN Surelog database, in BOTH views.
//
// `UhdmWriter::writeCont_assign` (Surelog src/DesignCompile/UhdmWriter.cpp
// :2121-2165) binds `cont_assign::Lhs->Actual_group` ONLY when all three hold:
//   (1) the Lhs is a plain `ref_obj` (a select is a `bit_select`, excluded);
//   (2) `bindVariable(mod, m, lhs->VpiName(), ...)` returns non-null, and that
//       walk (CompileStmt.cpp:3089-3151) knows function/task/begin/module_inst
//       ONLY -- a `gen_scope` falls to the default and recurses to its parent;
//   (3) `rhs->UhdmType() == uhdmoperation`.
// These rows vary each of the three independently, plus the RHS SELF-REFERENCE
// (`$bits(<target>)`) that the Earlgrey head carries.
module a1_bind118 #(parameter int W = 4) (
  input  logic [7:0] din,
  input  logic       c,
  output logic [7:0] dout,
  output logic       q
);
  logic [7:0] mod_vec;      // a MODULE-BODY vector
  logic       mod_bit;      // a MODULE-BODY scalar
  logic [7:0] shadow;       // a NAMESAKE for row r9

  for (genvar g = 0; g < 2; g++) begin : gb
    // r1 gen-local SCALAR, RHS an operation                 (op, gen-local)
    logic r1;
    assign r1 = din[0] & c;

    // r2 gen-local PACKED VECTOR, RHS an operation          (op, gen-local)
    logic [7:0] r2;
    assign r2 = din ^ 8'h0f;

    // r3 gen-local PACKED VECTOR, RHS a CAST of a CONSTANT width
    logic [7:0] r3;
    assign r3 = 8'({din[3:0], 4'b0});

    // r4 gen-local PACKED VECTOR, RHS a CAST whose width is $bits(SELF)
    //    -- the Earlgrey head's exact shape
    logic [7:0] r4;
    assign r4 = $bits(r4)'({din[3:0], 4'b0});

    // r5 gen-local SCALAR, RHS a CAST whose width is $bits(SELF)
    logic r5;
    assign r5 = $bits(r5)'(c);

    // r6 gen-local PACKED VECTOR, RHS a CAST whose width is $bits(ANOTHER
    //    gen-local) -- self-reference removed, cast kept
    logic [7:0] r6;
    assign r6 = $bits(r2)'({din[3:0], 4'b0});

    // r7 gen-local PACKED VECTOR, RHS a plain WHOLE REFERENCE (not an op)
    logic [7:0] r7;
    assign r7 = din;

    // r8 gen-local PACKED VECTOR, RHS a LITERAL (not an op)
    logic [7:0] r8;
    assign r8 = 8'hA5;

    // r9 gen-local PACKED VECTOR whose NAME also exists in the module body,
    //    RHS an operation -- bindVariable's namesake walk
    logic [7:0] shadow;
    assign shadow = din ^ 8'h33;

    // r10 MODULE-BODY vector assigned FROM a gen scope, RHS an operation
    //     (the target is found by bindVariable at the module_inst)
    // (declared above; assigned only in gb[0] to keep the design legal)
    if (g == 0) begin : one
      assign mod_vec = din | 8'h01;
      assign mod_bit = din[1] | c;
    end

    // r11 gen-local PACKED VECTOR, RHS a CAST of a $bits of the MODULE-BODY
    //     vector -- cast kept, self-reference removed, target still gen-local
    logic [7:0] r11;
    assign r11 = $bits(mod_vec)'({din[3:0], 4'b0});

    // r12 gen-local PACKED VECTOR, RHS an operation that READS the target
    //     itself outside a $bits (a combinational loop is legal to elaborate)
    logic [7:0] r12;
    assign r12 = din ^ 8'h07;
  end

  assign dout = mod_vec ^ gb[0].r2 ^ gb[1].r4 ^ gb[0].r3 ^ gb[1].r6 ^
                gb[0].r7 ^ gb[1].r8 ^ gb[0].shadow ^ gb[1].r11 ^ gb[0].r12;
  assign q = mod_bit ^ gb[0].r1 ^ gb[1].r5;
endmodule
