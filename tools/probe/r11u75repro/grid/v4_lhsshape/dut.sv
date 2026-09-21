// v11u74 v4 — LAW B, Lhs SHAPES THAT ARE NOT A PLAIN REFERENCE.  The patch
// only fires on a NamedValue Lhs; everything here must read byte-identical on
// both binaries, and must match whatever golden writes.
module dut (output logic [31:0] o);
  logic [31:0] pv;            // module-body namesake of a part-selected target
  logic [31:0] av [0:1];      // module-body namesake of an array target
  struct packed { logic [15:0] a; logic [15:0] b; } sv;
  logic [63:0] wide;          // module-body namesake, WIDER than the local
  logic  [7:0] narrow;        // module-body namesake, NARROWER than the local
  for (genvar i = 0; i < 1; i = i + 1) begin : gb
    logic [31:0] pv;          // written through a PART SELECT
    logic [31:0] av [0:1];    // written through an ELEMENT select
    struct packed { logic [15:0] a; logic [15:0] b; } sv;  // MEMBER target
    logic [31:0] wide;        // whole-name target, wider namesake
    logic [31:0] narrow;      // whole-name target, narrower namesake
    logic [31:0] cat0, cat1;
    assign pv[15:0] = 16'd1;
    assign av[0]    = 32'd2;
    assign sv.a     = 16'd3;
    assign wide     = 32'd4;
    assign narrow   = 32'd5;
    assign {cat0, cat1} = 64'd6;
  end
  assign o = gb[0].pv ^ gb[0].av[0] ^ 32'(gb[0].sv) ^ gb[0].wide
           ^ gb[0].narrow ^ gb[0].cat0 ^ gb[0].cat1
           ^ pv ^ av[0] ^ 32'(sv) ^ wide[31:0] ^ 32'(narrow);
endmodule
