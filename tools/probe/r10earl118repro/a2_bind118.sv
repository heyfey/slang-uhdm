// r10earl118 arm a2_bind118 -- the LEGS of the clone, and the SCOPE cut.
//
// MEASUREMENT ONLY.  `UhdmWriter::writeCont_assign` (Surelog
// src/DesignCompile/UhdmWriter.cpp) re-binds a continuous assign's target
// reference in exactly ONE place -- line 2165, inside
//   if (lhs is ref_obj) { var = bindVariable(mod, m, lhs->VpiName(), ...);
//                         if (var) { if (rhs is operation) { CLONE; ref->Actual_group(var); } } }
// and `bindVariable` (CompileStmt.cpp:3089-3151) knows function / task / begin
// / module_inst ONLY: a `gen_scope` falls to the default and recurses to its
// PARENT, so a generate-local name is never found there.  A CAST is the one
// operation kind that carries its OWN `Typespec`, which is what takes the
// :2237 clone branch, and the assign that branch installs carries no actual on
// an OWN-SCOPE generate-local target.  These rows separate the legs, the scope
// cut, and the target kinds.
module a2_bind118 (
  input  logic [7:0] din,
  input  logic       c,
  output logic [7:0] dout
);
  logic [7:0] mod_vec;
  logic [7:0] mod_cast;

  // the MODULE-BODY target with a CAST Rhs: bindVariable FINDS it, so the
  // :2165 arm re-binds after the clone.
  assign mod_cast = $bits(mod_cast)'({din[3:0], 4'b0});

  for (genvar g = 0; g < 2; g++) begin : ga
    // s1 unsized constant inside an operation Rhs  (DetectUnsizedConstant leg)
    logic [7:0] s1;
    assign s1 = din ^ '1;

    // s2 SIZED constant inside an operation Rhs    (control: no clone)
    logic [7:0] s2;
    assign s2 = din ^ 8'h0f;

    // s3 an operation Rhs of two sized constants
    logic [7:0] s3;
    assign s3 = 8'h0f ^ 8'h01;

    // s4 a CONCATENATION Rhs (an operation with no typespec of its own)
    logic [7:0] s4;
    assign s4 = {din[3:0], 4'b0};

    // s5 a TERNARY Rhs
    logic [7:0] s5;
    assign s5 = c ? din : 8'h00;

    // s6 a CAST Rhs whose target is an ANCESTOR generate scope's local
    logic [7:0] s6;
    logic [7:0] s2b;
    if (g == 0) begin : anc
      assign s6 = $bits(s6)'({din[3:0], 4'b0});
      // s2b an ANCESTOR gen scope's local with a NON-cast operation Rhs
      assign s2b = din ^ 8'h0f;
    end

    // s8 a CAST Rhs one generate level DEEPER, OWN-scope target
    if (g < 2) begin : deep
      logic [7:0] s8;
      assign s8 = $bits(s8)'({din[3:0], 4'b0});
      logic [7:0] s9;
      assign s9 = din ^ 8'h0f;
    end

    // s10 a CAST Rhs whose target is a generate-local NET (wire), not a var
    wire [7:0] s10;
    assign s10 = $bits(s10)'({din[3:0], 4'b0});
    wire [7:0] s11;
    assign s11 = din ^ 8'h0f;

    // s12 a CAST spelled with a TYPE name rather than a width
    typedef logic [7:0] byte8_t;
    logic [7:0] s12;
    assign s12 = byte8_t'({din[3:0], 4'b0});

    // s13 a SIGNEDNESS cast nested in a width cast
    logic [7:0] s13;
    assign s13 = 8'(signed'(din));
  end

  assign mod_vec = din | 8'h01;
  assign dout = mod_vec ^ mod_cast ^ ga[0].s1 ^ ga[1].s2 ^ ga[0].s3 ^
                ga[1].s4 ^ ga[0].s5 ^ ga[1].s6 ^ ga[0].s2b ^
                ga[1].deep.s8 ^ ga[0].deep.s9 ^ ga[1].s10 ^ ga[0].s11 ^
                ga[1].s12 ^ ga[0].s13;
endmodule
