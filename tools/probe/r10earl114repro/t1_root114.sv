// r10earl114 arm t1 -- THE ROOT-KIND AXIS.  MEASUREMENT ONLY.
//
// THE HEAD (reproduced byte for byte by r10earl113's s1_scope113 arm, and by
// cell r1 below): golden hangs a `ref_typespec -> array_typespec` on the
// pattern-carried `hier_path tl_h_i[0].a_valid` and we hang NOTHING.
//
// THE DECODE, read off Surelog and not guessed --
// `CompileHelper::compileSelectExpression`
// (src/DesignCompile/CompileExpression.cpp:5455-5496):
//
//     UHDM::hier_path *path = s.MakeHier_path();
//     if (instance && (reduce == Reduce::Yes)) {                 // THE GATE
//       UHDM::any *rootValue = getObject(the_name, component, ..., instance, pexpr);
//       if (rootValue) {
//         if (expr *expval = any_cast<expr *>(rootValue)) {
//           path->Root_value(rootValue);
//           if (ref_typespec *expval_rt = expval->Typespec()) {
//             ... ref_typespec *path_rt = s.MakeRef_typespec();
//                 path_rt->VpiParent(path); path->Typespec(path_rt);
//             path->Typespec()->Actual_typespec(expval_rt->Actual_typespec());
//           }
//         } else if (UHDM::port *expval = any_cast<port *>(rootValue)) {
//           path->Root_value(expval->Low_conn());          // NO TYPESPEC
//         } else if (param_assign *passign = any_cast<param_assign *>(rootValue)) {
//           path->Root_value(passign->Rhs());
//           ... the PARAMETER's own typespec ...
//         }
//       }
//     }
//
// So the Root_value and the typespec are ONE binding off ONE object, and the
// object is whatever `getObject` (CompileExpression.cpp:125-240) returns.  That
// function searches the instance netlist in a FIXED ORDER --
//     array_nets() -> nets() -> variables() -> ports() -> param_assigns()
// -- climbing from the generate instance outwards through generate-kind
// instances only.  The ROOT KIND is therefore an axis of its own, and it is the
// over-fire risk this arm exists to measure: a NET root, a PORT root and a
// PARAMETER root take three different branches, and a root with NO typespec
// takes none of them.
//
// Every cell below is the SAME shape as the head: a generate-for at depth 1,
// a KEYED assignment pattern in a continuous assign, whose target is declared
// in that generate block and carries an ENUM member (which is what makes
// Surelog model it a `struct_var`, so UHDM's `cont_assign::DeepClone` flattens
// the pattern -- r10earl113 section 3).  ONLY THE ROOT OF THE FIRST MEMBER
// VALUE'S DOTTED PATH CHANGES.
package p114;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {         // no enum member -> Surelog: struct_net
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_net_t;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
  } inner_t;
  typedef struct packed {
    inner_t     sub;
    logic [7:0] a_data;
  } outer_t;
endpackage

module t1_root114 #(parameter int M = 3) (
  input  logic          clk,
  input  p114::h2d_t    tl_h_i [M],      // r1: PORT array of a TYPEDEF struct
  input  logic [7:0]    d_i,
  output logic          v_o
);
  // ---- the roots -------------------------------------------------------
  p114::h2d_t     mv_arr [M];            // r2: module VARIABLE array
  wire p114::h2d_net_t wn_arr [M];       // r3: module WIRE (net) array
  p114::outer_t   ov_arr [M];            // r6: nested-struct array (deeper path)
  struct packed { logic a_valid; logic [2:0] a_opcode; }
                  an_arr [M];            // r8: ANONYMOUS type array
  localparam p114::h2d_t LP_ONE = '{a_valid: 1'b1, a_opcode: p114::OpB, a_data: 8'h5};

  // The source arrays are driven ELEMENT BY ELEMENT at module scope: this
  // pass's law lives in a GENERATE scope, and a module-scope driver keeps the
  // roots out of the measured population instead of adding cells of its own.
  assign mv_arr[0] = '{a_valid: 1'b0, a_opcode: p114::OpA, a_data: d_i};
  assign mv_arr[1] = '{a_valid: 1'b1, a_opcode: p114::OpB, a_data: d_i};
  assign mv_arr[2] = '{a_valid: 1'b0, a_opcode: p114::OpA, a_data: d_i};
  assign wn_arr[0] = '{a_valid: 1'b1, a_opcode: 3'b001, a_data: d_i};
  assign wn_arr[1] = '{a_valid: 1'b0, a_opcode: 3'b010, a_data: d_i};
  assign wn_arr[2] = '{a_valid: 1'b1, a_opcode: 3'b011, a_data: d_i};
  assign ov_arr[0] = '{sub: '{a_valid: 1'b1, a_opcode: 3'b011}, a_data: d_i};
  assign ov_arr[1] = '{sub: '{a_valid: 1'b0, a_opcode: 3'b100}, a_data: d_i};
  assign ov_arr[2] = '{sub: '{a_valid: 1'b1, a_opcode: 3'b101}, a_data: d_i};
  assign an_arr[0] = '{a_valid: 1'b0, a_opcode: 3'b100};
  assign an_arr[1] = '{a_valid: 1'b1, a_opcode: 3'b101};
  assign an_arr[2] = '{a_valid: 1'b0, a_opcode: 3'b110};

  // r1  ROOT = a PORT-declared unpacked array of a TYPEDEF'd struct.
  //     Surelog's netlist holds an `array_var` for it (`variables()`), so
  //     getObject returns an EXPR and the expr branch runs.  THE CORPUS CELL.
  for (genvar i = 0; i < M; i++) begin : gen_r1
    p114::h2d_t r1_t;
    assign r1_t = '{ a_valid:  tl_h_i[i].a_valid,
                     a_opcode: tl_h_i[i].a_opcode,
                     a_data:   d_i };
  end

  // r2  ROOT = a MODULE-SCOPE VARIABLE unpacked array (array_var, not a port).
  for (genvar i = 0; i < M; i++) begin : gen_r2
    p114::h2d_t r2_t;
    assign r2_t = '{ a_valid:  mv_arr[i].a_valid,
                     a_opcode: mv_arr[i].a_opcode,
                     a_data:   d_i };
  end

  // r3  ROOT = a WIRE array -- `getObject` reaches `array_nets()` FIRST, so
  //     this is the array_NET half of the root-kind axis and the named
  //     over-fire risk.
  for (genvar i = 0; i < M; i++) begin : gen_r3
    p114::h2d_t r3_t;
    assign r3_t = '{ a_valid:  wn_arr[i].a_valid,
                     a_opcode: p114::OpA,
                     a_data:   d_i };
  end

  // r4  ROOT = a plain packed-struct object, NO index: the path is two
  //     ref_objs and the root's typespec is a struct_typespec, not an array
  //     one.  (Does the law depend on the typespec KIND?  earl53's a2 cell
  //     says no for the connection site; this measures it here.)  THE ROOT IS
  //     DECLARED IN THE GENERATE BLOCK: Surelog's UHDM elaborator reports
  //     `[ERR:UH0725] Unresolved hierarchical reference` for a MODULE-scope
  //     undotted struct read from inside a generate scope, and an arm whose
  //     golden is an error message is not an arm that tests anything.
  for (genvar i = 0; i < M; i++) begin : gen_r4
    p114::h2d_t r4_src;
    p114::h2d_t r4_t;
    assign r4_src = '{a_valid: 1'b1, a_opcode: p114::OpA, a_data: d_i};
    assign r4_t = '{ a_valid:  r4_src.a_valid,
                     a_opcode: r4_src.a_opcode,
                     a_data:   d_i };
  end

  // r5  ROOT = a struct NET (a pure-logic struct driven by a continuous
  //     assign -- r10earl113 section 3's struct_net shape).  `getObject`
  //     reaches `nets()` BEFORE `variables()`, so this is the net half of the
  //     root-kind axis for an undotted root.
  for (genvar i = 0; i < M; i++) begin : gen_r5
    p114::h2d_net_t r5_src;
    p114::h2d_t r5_t;
    assign r5_src = '{a_valid: 1'b0, a_opcode: 3'b010, a_data: d_i};
    assign r5_t = '{ a_valid:  r5_src.a_valid,
                     a_opcode: p114::OpB,
                     a_data:   d_i };
  end

  // r6  A DEEPER PATH over a nested-struct array root (three components).
  for (genvar i = 0; i < M; i++) begin : gen_r6
    p114::h2d_t r6_t;
    assign r6_t = '{ a_valid:  ov_arr[i].sub.a_valid,
                     a_opcode: p114::OpA,
                     a_data:   ov_arr[i].a_data };
  end

  // r7  ROOT = a LOCALPARAM of struct type -- getObject's `param_assigns()`
  //     row and the `param_assign` branch (Root_value = the Rhs, typespec =
  //     the PARAMETER's own).
  for (genvar i = 0; i < M; i++) begin : gen_r7
    p114::h2d_t r7_t;
    assign r7_t = '{ a_valid:  LP_ONE.a_valid,
                     a_opcode: LP_ONE.a_opcode,
                     a_data:   d_i };
  end

  // r8  ROOT = an ANONYMOUS-typed array: the root object may carry NO
  //     ref_typespec at all, in which case golden hangs NOTHING and a law that
  //     hung our own typespec would be an AWAY move.
  for (genvar i = 0; i < M; i++) begin : gen_r8
    p114::h2d_t r8_t;
    assign r8_t = '{ a_valid:  an_arr[i].a_valid,
                     a_opcode: p114::OpA,
                     a_data:   d_i };
  end

  // r9  ROOT DECLARED IN THE SAME GENERATE BLOCK -- getObject climbs from the
  //     generate instance, so a gen-local root is found in the gen instance's
  //     OWN netlist.
  for (genvar i = 0; i < M; i++) begin : gen_r9
    p114::h2d_t r9_src [2];
    p114::h2d_t r9_t;
    assign r9_src[0] = '{a_valid: 1'b1, a_opcode: p114::OpA, a_data: d_i};
    assign r9_src[1] = '{a_valid: 1'b0, a_opcode: p114::OpB, a_data: d_i};
    assign r9_t = '{ a_valid:  r9_src[1].a_valid,
                     a_opcode: r9_src[1].a_opcode,
                     a_data:   d_i };
  end

  // r10 ROOT DECLARED IN AN ENCLOSING GENERATE BLOCK, read from a nested one:
  //     the fence's REACH.  `getObject` climbs from the innermost generate
  //     instance outwards through generate-kind instances, so an ancestor
  //     generate block's local is reached by the SAME search that misses the
  //     innermost one's.
  for (genvar i = 0; i < M; i++) begin : gen_r10a
    p114::h2d_t r10_src [2];
    assign r10_src[0] = '{a_valid: 1'b1, a_opcode: p114::OpA, a_data: d_i};
    assign r10_src[1] = '{a_valid: 1'b0, a_opcode: p114::OpB, a_data: d_i};
    for (genvar j = 0; j < 2; j++) begin : gen_r10b
      p114::h2d_t r10_t;
      assign r10_t = '{ a_valid:  r10_src[1].a_valid,
                        a_opcode: r10_src[1].a_opcode,
                        a_data:   d_i };
    end
  end

  assign v_o = mv_arr[0].a_valid ^ wn_arr[0].a_valid ^
               ov_arr[0].a_data[0] ^ an_arr[0].a_valid ^ LP_ONE.a_valid;
endmodule
