// pw20.sv — PASS 20: the REGRESSION that § genCaOpDeepBindGenLocal20 produced
// in u2r genvar_loop_decl_3 (testflags CMP_EQUAL -> CMP_NOTEQUAL), turned into
// a witness.  That test's gen block is
//     if (1) begin : gen
//       integer x, y;
//       for (genvar x = 0; x < 2; x++)
//         if (x == 0) initial gen.x = 10;
//       assign y = x + 1;
//     end
// LHS `y` and RHS `x` are both same-scope gen locals, so the new law binds `x`
// — and golden leaves it null, where ps20's `assign s1 = v1 ^ 4'h5;` binds.
// Candidate discriminators, one row each: the variable's TYPE (integer_var vs
// logic_var), the driver reaching it through a HIERARCHICAL name from a nested
// gen block, and the gen local SHADOWING a module-level name.
`default_nettype none
module pw20 (
    output reg [15:0] x,
    output reg [15:0] o1,
    output reg [15:0] o2,
    output reg [15:0] o3
);

  // W1 — integer gen locals, flat, no shadowing
  if (1) begin : g1
    integer p, q;
    initial p = 10;
    assign q = p + 1;
  end

  // W2 — the same with logic
  if (1) begin : g2
    logic [15:0] p, q;
    initial p = 10;
    assign q = p + 1;
  end

  // W3 — integer, driven from a NESTED gen block through a HIER name
  if (1) begin : g3
    integer p, q;
    if (1) begin : g3i
      initial g3.p = 10;
    end
    assign q = p + 1;
  end

  // W4 — integer gen local SHADOWING the module output `x`
  if (1) begin : g4
    integer x, q;
    initial x = 10;
    assign q = x + 1;
  end

  // W5 — the EXACT genvar_loop_decl_3 `gold` shape: the driver sits inside a
  // nested FOR-generate.
  if (1) begin : g5
    integer p, q;
    genvar z;
    for (z = 0; z < 2; z++)
      if (z == 0)
        initial p = 10;
    assign q = p + 1;
  end

  // W6 — the same nested for-generate is PRESENT but the driver is direct.
  if (1) begin : g6
    integer p, q, r;
    genvar z;
    for (z = 0; z < 2; z++)
      if (z == 0)
        initial r = 10;
    initial p = 10;
    assign q = p + 1;
  end

  initial x = 0;
  assign o1 = g1.q;
  assign o2 = g2.q;
  assign o3 = g3.q ^ g4.q ^ g5.q ^ g6.q;

endmodule
