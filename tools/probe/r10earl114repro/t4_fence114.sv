// r10earl114 arm t4 -- THE FENCE ARM: every shape where this law could HANG A
// TYPESPEC GOLDEN LEAVES BARE (an AWAY move).  MEASUREMENT ONLY.
//
// The three branches of Surelog's binding (CompileExpression.cpp:5457-5496)
// are not interchangeable:
//
//   * `expr*`        -> Root_value = the object, typespec = ITS typespec's
//                       Actual_typespec.                     <- the law
//   * `port*`        -> Root_value = the port's Low_conn, and NO TYPESPEC AT
//                       ALL.                                 <- fence
//   * `param_assign*`-> Root_value = the Rhs, typespec = the PARAMETER's.
//   * anything else (a task_func `io_decl`, which is a plain BaseClass) ->
//                       NEITHER field is written.            <- fence
//
// and the whole `if` is gated on `instance && reduce == Reduce::Yes`, so the
// DEFINITION view (no instance) must be bare on both sides in every cell here.
//
// The r10earl113 cells x1 / x2 / x3 are repeated because this law rides the
// SAME emitter site as that one (`flattenPatternCaRhs`) and its fences are this
// law's inherited floor: the struct_NET target golden never flattens, the
// MODULE-BODY target golden sizes, and the bit_select Lhs.
package p114f;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {          // no enum member -> a struct_NET
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_net_t;
endpackage

interface if114 (input logic clk);
  p114f::h2d_t bus [2];
  logic        rdy;
  modport mp (input bus, output rdy);
endinterface

module t4_child114 #(parameter int M = 2) (
  input  p114f::h2d_t ch_i [M],
  input  logic [7:0]  d_i,
  output logic        o
);
  // f7  the SAME head shape one instance down: a child module's generate
  //     scope.  `getObject` climbs the CHILD's netlist, never the parent's.
  for (genvar i = 0; i < M; i++) begin : gen_f7
    p114f::h2d_t f7_t;
    assign f7_t = '{ a_valid:  ch_i[i].a_valid,
                     a_opcode: ch_i[i].a_opcode,
                     a_data:   d_i };
  end
  assign o = ch_i[0].a_valid;
endmodule

module t4_fence114 #(parameter int M = 3) (
  input  logic         clk,
  input  p114f::h2d_t  tl_h_i [M],
  input  logic [7:0]   d_i,
  output logic         v_o
);
  p114f::h2d_t     x2_modtgt;
  p114f::h2d_t     x3_arr [M];
  p114f::h2d_t     ch_src [2];
  logic            cho;

  if114 u_if (.clk(clk));

  // f1 (= r10earl113 x1)  A PURE-LOGIC struct target comes out a `struct_net`;
  //     UHDM's `cont_assign::DeepClone` refuses to flatten and golden keeps the
  //     `tagged_pattern`, so golden has NO first operand of our kind here at
  //     all.  A move here is NOGOLD, never TO-GOLDEN and never AWAY.
  for (genvar i = 0; i < M; i++) begin : gen_f1
    p114f::h2d_net_t f1_net;
    assign f1_net = '{ a_valid:  tl_h_i[i].a_valid,
                       a_opcode: 3'b010,
                       a_data:   d_i };
  end

  // f2 (= r10earl113 x2)  THE PATTERN IS INSIDE A GENERATE BLOCK BUT THE TARGET
  //     IS DECLARED IN THE MODULE BODY -- `bindVariable` finds it, so golden
  //     takes `expandPatternAssignment` and SIZES operand 0.  r10earl113's
  //     size law is fenced off this cell; this pass must not move it either.
  if (M > 1) begin : gen_f2
    assign x2_modtgt = '{ a_valid:  tl_h_i[0].a_valid,
                          a_opcode: tl_h_i[0].a_opcode,
                          a_data:   d_i };
  end

  // f3 (= r10earl113 x3)  A MODULE-SCOPE ARRAY ELEMENT target: the Lhs is a
  //     `bit_select`, not a `ref_obj`, so `writeCont_assign`'s ref_obj arm
  //     never runs.
  for (genvar i = 0; i < M; i++) begin : gen_f3
    assign x3_arr[i] = '{ a_valid:  tl_h_i[i].a_valid,
                          a_opcode: tl_h_i[i].a_opcode,
                          a_data:   d_i };
  end

  // f4  A ROOT REACHED THROUGH AN INTERFACE INSTANCE (`u_if.bus[i].a_valid`).
  //     The head component is an interface instance, not a net/var/port of this
  //     module's netlist, so `getObject`'s netlist search MISSES and the
  //     binding never happens on golden's side.
  for (genvar i = 0; i < 2; i++) begin : gen_f4
    p114f::h2d_t f4_t;
    assign f4_t = '{ a_valid:  u_if.bus[i].a_valid,
                     a_opcode: u_if.bus[i].a_opcode,
                     a_data:   d_i };
  end

  // f5  THE SAME PATTERN INSIDE A FUNCTION called from a generate-scope
  //     continuous assign: the path's root is the function's own FORMAL, whose
  //     netlist object is a task_func `io_decl` -- a plain BaseClass, so NONE
  //     of the three branches runs and golden binds NEITHER field.
  function automatic p114f::h2d_t mk5(input p114f::h2d_t a);
    return '{ a_valid: a.a_valid, a_opcode: a.a_opcode, a_data: d_i };
  endfunction
  for (genvar i = 0; i < M; i++) begin : gen_f5
    p114f::h2d_t f5_t;
    assign f5_t = mk5(tl_h_i[i]);
  end

  // f6  A PATTERN WHOSE MEMBER VALUE IS A USER SUBROUTINE CALL ARGUMENT --
  //     r10earl112's committed fence (f), § patCaGenIdxNeverInUserCallArg112v:
  //     `compileTfCallArguments` compiles the argument with `pexpr = call`, so
  //     the pattern's `Reduce::Yes` never reaches it.
  function automatic logic pick6(input logic a);
    return a;
  endfunction
  for (genvar i = 0; i < M; i++) begin : gen_f6
    p114f::h2d_t f6_t;
    assign f6_t = '{ a_valid:  pick6(tl_h_i[i].a_valid),
                     a_opcode: tl_h_i[i].a_opcode,
                     a_data:   d_i };
  end

  // f7  is inside t4_child114 above.
  // (element-wise, not `'{default: ...}`: an unpacked-array `default:` pattern
  //  SEGFAULTS Surelog in `Creating UHDM Model` -- bisected cell by cell, and
  //  slang rejects it too.  Neither is this pass's business; the arm simply
  //  does not spell it.)
  assign ch_src[0] = '{a_valid: 1'b1, a_opcode: p114f::OpA, a_data: d_i};
  assign ch_src[1] = '{a_valid: 1'b0, a_opcode: p114f::OpB, a_data: d_i};
  t4_child114 #(.M(2)) u_ch (.ch_i(ch_src), .d_i(d_i), .o(cho));

  // f8  r10earl110's committed shape: a genvar-bounded PART SELECT in a PLAIN
  //     gen-scope continuous assign (the genvar stays SPELLED there).
  for (genvar i = 0; i < M; i++) begin : gen_f8
    logic [1:0] f8_t;
    assign f8_t = tl_h_i[i].a_data[8 - 1 -: 2];
  end

  assign u_if.rdy = 1'b1;
  assign v_o = x2_modtgt.a_valid ^ x3_arr[0].a_valid ^ cho;
endmodule
