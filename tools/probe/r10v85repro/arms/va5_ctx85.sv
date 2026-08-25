// v85 adversarial arm A5 — the same size(-1) shapes OUTSIDE a param_assign:
// net/var declarations, continuous assignments, port actuals, ranges, cases,
// function bodies.  These are the places a widened tryFoldConst refusal could
// leak into.
module va5_sub85 #(parameter int P = 4) (input logic [7:0] a, output logic [7:0] y);
  assign y = a ^ P[7:0];
endmodule
module va5_ctx85 #(parameter int W = 8) ();
  logic [7:0] a;
  // continuous-assign RHS carrying the shape
  logic [31:0] w1, w2, w3, w4;
  assign w1 = ~(('h1 << W) - 1'b1);
  assign w2 = ~((32'h1 << W) - 1'b1);
  assign w3 = ('h1 << W);
  assign w4 = ~('hff);
  // net decl assign
  wire [31:0] n1 = ~(('h1 << W) - 1'b1);
  wire [31:0] n2 = ~('hff);
  // var initializer
  logic [31:0] v1 = ~(('h1 << W) - 1'b1);
  // packed range bound
  localparam int RB = 4;
  logic [(('h1 << RB) - 1'b1):0] r1;
  logic [((32'h1 << RB) - 1):0]  r2;
  // port actual
  va5_sub85 #(.P(~(('h1 << 2) - 1'b1))) u1 (.a(a), .y());
  va5_sub85 #(.P(~((32'h1 << 2) - 1)))  u2 (.a(a), .y());
  // procedural
  logic [31:0] p1;
  always_comb begin
    p1 = ~(('h1 << W) - 1'b1);
    case (a)
      ~(('h1 << 2) - 1'b1): p1 = 1;
      default: p1 = 0;
    endcase
  end
  // replication / concat with the family
  localparam logic [31:0] q1 = ~{4{'h1}};
  localparam logic [31:0] q2 = ~{'h1, 'h1};
  localparam logic [31:0] q3 = {('h1 << 2){1'b1}};
endmodule
