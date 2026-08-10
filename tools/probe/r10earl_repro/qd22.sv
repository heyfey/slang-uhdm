// qd22.sv — PASS 22.  The layer behind the ternary laws:
//   work@top_earlgrey > .. > ex_block_i > gen_multdiv_single_cycle
//     > multdiv_i > gen_multiv_single_cycle > gen_scope
//       > cont_assign ibex_multdiv_fast.sv:147:12 > operation {op=25}
//         > sys_func_call '$signed' > operation {op=33} concat
//           > ref_obj 'mult1_sign_a' :147:33 > vpiActual
//   golden logic_var 'mult1_sign_a' (:142:25), ours <null>.
// The source is
//   assign mult1_res = $signed({mult1_sign_a, mult1_op_a}) * $signed(..);
// with EVERY name a local of that same gen block — i.e. exactly
// § genCaOpDeepBindGenLocal20 (Lhs is a gen-local variable => every same-scope
// gen-local read in the Rhs binds), whose WALK descends through `operation`
// nodes only and therefore stops at the `$signed` call.
// Rows below cross the containers the walk may have to cross: a system call, a
// system call over a concat, a USER function call, a bit-select, a part-select
// and a nested operation, each read from a gen-local-LHS cont_assign; plus the
// module-LHS negatives that must stay unbound.
module qd22 (
    input  logic [3:0] pa,
    output logic [7:0] oy1,
    output logic [7:0] oy2
);
  function automatic logic [3:0] f4(input logic [3:0] x);
    return x ^ 4'h1;
  endfunction

  logic [7:0] my1, my2;
  assign oy1 = my1;
  assign oy2 = my2;

  if (1) begin : gen_b
    logic signed [7:0] r1, r2, r3, r4, r5, r6;
    // PROCEDURALLY driven, so these stay logic_VAR in both models — the
    // corpus shape (ibex_multdiv_fast's mult1_sign_a is written by the gen
    // block's always_comb).  A continuously-assigned gen local becomes a
    // logic_NET and § genCaOpDeepBindGenLocal20 excludes net kinds, which is
    // the first cut of this witness measuring `ok` everywhere for the wrong
    // reason.
    logic [3:0] v1;
    logic       s1;

    always_comb begin
      v1 = pa;
      s1 = pa[0];
    end

    assign r1 = $signed(v1);                 // D1 sys call, bare arg
    assign r2 = $signed({s1, v1});           // D2 sys call over a concat
    assign r3 = f4(v1);                      // D3 user function call
    assign r4 = v1[1];                       // D4 bit-select of a gen local
    assign r5 = v1[2:1];                     // D5 part-select of a gen local
    assign r6 = (v1 ^ 4'h5) + {s1, 3'b0};    // D6 nested operations (pass 20)

    // module-LHS negatives: nothing in these binds
    assign my1 = $signed({s1, v1});          // D7
    assign my2 = v1 ^ 4'h5;                  // D8
  end
endmodule
