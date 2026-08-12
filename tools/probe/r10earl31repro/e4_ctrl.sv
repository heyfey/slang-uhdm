// r10earl31 arm e4 — THE OVER-FIRE CONTROL and the EDGE CASES the standing rules
// demand of any new gate.
//
//   k1  a child module INSTANTIATED TWICE, so the same process statement exists
//       in the module DEF listing AND in two ELABORATED instance views: does
//       golden stamp EVERY copy?  (qa20/§ elabConnSelFoldNoTs21 is the recorded
//       precedent for a def-only stamp, so this must be measured, not assumed.)
//   k2  an ESCAPED IDENTIFIER as the selected signal's name, containing the very
//       character a name-keyed gate would key on (`\d@x `) — the standing rule
//       says test escaped identifiers on every gate that reads names.
//   k3  the bound written by a MACRO (`\`WPS`), so the fold's source range is a
//       macro location.
//   k4  a THREE-level hier_path part_select (struct in struct).
//   k5  always_ff (a clocked process) and an initial block.
//   k6  a generate-scope process.
//   k7  literal-only bounds and a MODULE-localparam bound: must never be stamped.
`define WPS pk::DC
package pk;
  localparam logic [3:0] DC = 4'h2;
  typedef struct packed { logic [7:0] lo; logic [7:0] hi; } inner_t;
  typedef struct packed { inner_t a; logic [15:0] b; } outer_t;
endpackage

module e4child (
  input  logic [31:0] d,
  input  logic        clk,
  input  pk::outer_t  o,
  output logic [31:0] y,
  output logic [31:0] q
);
  localparam logic [3:0] ML = 4'h3;
  logic [31:0] \d@x ;
  logic [31:0] r1, r2, r3, r4, r5, r6;

  always_comb begin : \blk@1 
    r1 = 32'(d[pk::DC-1:0]);          // k1/k2 base cell (def + 2 elab views)
    r2 = 32'(\d@x [pk::DC-1:0]);      // k2 escaped selected name
    r3 = 32'(d[`WPS-1:0]);            // k3 macro-written bound
    r4 = 32'(o.a[pk::DC-1:0]);        // k4 hier_path, member of a nested struct
    r5 = 32'(d[ML-1:0]);              // k7 MODULE localparam — must not stamp
    r6 = 32'(d[3:0]);                 // k7 literal bounds — must not stamp
  end

  always_ff @(posedge clk) begin      // k5
    q <= 32'(d[pk::DC-1:0]);
  end

  assign y = r1 ^ r2 ^ r3 ^ r4 ^ r5 ^ r6;
endmodule

module e4 (
  input  logic [31:0] d,
  input  logic        clk,
  input  pk::outer_t  o,
  output logic [31:0] y
);
  logic [31:0] y1, y2, q1, q2, g1;
  e4child u1 (.d(d), .clk(clk), .o(o), .y(y1), .q(q1));
  e4child u2 (.d(~d), .clk(clk), .o(o), .y(y2), .q(q2));

  for (genvar gi = 0; gi < 2; gi++) begin : gblk      // k6
    always_comb begin : ginner
      g1 = 32'(d[pk::DC-1:0]);
    end
  end

  initial begin                                      // k5
    y = 32'(d[pk::DC-1:0]);
  end

  assign y = y1 ^ y2 ^ q1 ^ q2 ^ g1;
endmodule
