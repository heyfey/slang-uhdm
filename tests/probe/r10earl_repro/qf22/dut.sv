// qf22.sv — PASS 22.  qe22 showed the child-instance axis matters for the BARE
// `$signed(v)` argument but still did NOT reproduce the corpus head, where
// golden binds a CONCAT operand inside `$signed({..})`.  The remaining
// difference from ibex_multdiv_fast is how the read locals are DRIVEN: there
// they are CONTINUOUSLY assigned (`assign mult1_sign_a = 1'b0;`,
// `assign mult1_op_a = op_a_i[15:0];`) while qd22/qe22 drove them from an
// always_comb.  These rows write the corpus statements verbatim and add the
// driver-shape contrast beside them.
module qf22_child #(
    parameter bit SC = 1'b1
) (
    input  logic [31:0] op_a_i,
    input  logic [31:0] op_b_i,
    input  logic        pc,
    output logic [33:0] oy
);
  if (SC) begin : gen_b
    logic signed [33:0] mult1_res;
    logic [15:0]        mult1_op_a, mult1_op_b;
    logic               mult1_sign_a, mult1_sign_b;

    // ibex_multdiv_fast.sv:160-163 verbatim
    assign mult1_sign_a = 1'b0;
    assign mult1_sign_b = 1'b0;
    assign mult1_op_a = op_a_i[15:0];
    assign mult1_op_b = op_b_i[15:0];

    // ibex_multdiv_fast.sv:147 verbatim — THE HEAD
    assign mult1_res = $signed({mult1_sign_a, mult1_op_a}) *
                       $signed({mult1_sign_b, mult1_op_b});

    // contrast rows, same block, procedural drivers
    logic       pv_s;
    logic [15:0] pv_o;
    logic signed [33:0] pv_res;
    always_comb begin
      pv_s = pc;
      pv_o = op_a_i[15:0];
    end
    assign pv_res = $signed({pv_s, pv_o}) * $signed({pv_s, pv_o});

    assign oy = mult1_res ^ pv_res;
  end
endmodule

module qf22 (
    input  logic [31:0] op_a_i,
    input  logic [31:0] op_b_i,
    input  logic        pc,
    output logic [33:0] oy
);
  qf22_child u_c (.op_a_i(op_a_i), .op_b_i(op_b_i), .pc(pc), .oy(oy));
endmodule
