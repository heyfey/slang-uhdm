// r11u46 GOLDEN GRID — signed'/unsigned' casts in def-view syntax positions.
module grid #(
    parameter int unsigned N = 4
) (
    input  logic [7:0] in_i,
    output logic [7:0] out_o
);
  localparam int unsigned M = 3;

  // A: condition LHS is unsigned'(genvar)  -- the TARGET cell
  for (genvar a = 0; unsigned'(a) < N; a++) begin : g_a
    assign out_o[0] = in_i[0];
  end

  // B: condition LHS is signed'(genvar)
  for (genvar b = 0; signed'(b) < N; b++) begin : g_b
    assign out_o[1] = in_i[1];
  end

  // C: condition RHS is unsigned'(param)
  for (genvar c = 0; c < unsigned'(N); c++) begin : g_c
    assign out_o[2] = in_i[2];
  end

  // D: cast nested inside a binary sub-expression
  for (genvar d = 0; (unsigned'(d) + 1) < N; d++) begin : g_d
    assign out_o[3] = in_i[3];
  end

  // E: explicit $unsigned system call (control)
  for (genvar e = 0; $unsigned(e) < N; e++) begin : g_e
    assign out_o[4] = in_i[4];
  end

  // F: int'(genvar) cast (control -- already handled by CastExpression)
  for (genvar f = 0; int'(f) < N; f++) begin : g_f
    assign out_o[5] = in_i[5];
  end

  // G: cast in the INIT expression
  for (genvar g = unsigned'(M); g < N; g++) begin : g_g
    assign out_o[6] = in_i[6];
  end

  // H: cast in the INCREMENT expression
  for (genvar h = 0; h < N; h = h + unsigned'(1)) begin : g_h
    assign out_o[7] = in_i[7];
  end

  // I: unary over a cast
  for (genvar i = 0; !unsigned'(i) == 0; i++) begin : g_i
    assign out_o[0] = in_i[0];
  end

  // J: BOTH operands cast
  for (genvar j = 0; unsigned'(j) < unsigned'(N); j++) begin : g_j
    assign out_o[1] = in_i[1];
  end

  // K: cast in a gen-IF condition (def view, not a gen_for)
  if (unsigned'(M) < N) begin : g_k
    assign out_o[2] = in_i[2];
  end

  // L: cast in a localparam value (def view param_assign)
  localparam int unsigned L = unsigned'(M) + 1;

  // M: cast in a net range bound (def view)
  logic [unsigned'(M):0] mnet;
  assign mnet = '0;

  // N: cast in a gen-CASE selector
  case (unsigned'(M))
    3: begin : g_n
      assign out_o[3] = in_i[3];
    end
    default: begin : g_nd
      assign out_o[3] = in_i[4];
    end
  endcase

  // O: a loop wrapped in an explicit generate region (placeholder path)
  generate
    for (genvar o = 0; unsigned'(o) < N; o++) begin : g_o
      assign out_o[4] = in_i[5];
    end
  endgenerate
endmodule

// P: the SAME loop inside an INTERFACE def view (CompileInterface expands it)
interface gridif #(parameter int unsigned N = 4) ();
  for (genvar p = 0; unsigned'(p) < N; p++) begin : g_p
    logic w;
  end
endinterface

module gridtop (input logic [7:0] i_i, output logic [7:0] o_o);
  grid #(.N(4)) u_grid (.in_i(i_i), .out_o(o_o));
  gridif #(.N(4)) u_if ();
endmodule
