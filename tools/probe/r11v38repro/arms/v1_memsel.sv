// v11u38 adversarial arm 1 — the member-select size-form unpacked dimension.
package mp1;
  typedef struct packed { logic [7:0] a; logic [15:0] b; logic [7:0] c; } t3;
  parameter t3 PP = {8'd3, 16'd9, 8'd5};
endpackage

typedef struct packed { logic [31:0] t; } ts1_t;
typedef struct packed { logic signed [7:0] s; logic [3:0] u; } tsg_t;
typedef struct packed { logic [3:0] x; logic [3:0] y; } inner_t;
typedef struct packed { inner_t n; logic [7:0] m; } outer_t;
typedef enum logic [3:0] { E0 = 4'd6, E1 = 4'd7 } e_t;
typedef struct packed { e_t e; logic [3:0] f; } te_t;
typedef union packed { logic [7:0] ua; logic [7:0] ub; } un_t;
typedef struct packed { un_t w; logic [7:0] v; } tu_t;

module v1_m #(parameter ts1_t P1 = 32'h4,
              parameter tsg_t PG = 12'h0F5,
              parameter outer_t PO = 16'h5A3C,
              parameter te_t PE = 8'h6A,
              parameter tu_t PU = 16'h0709) ();
  logic mem1 [P1.t];        // the corpus shape
  wire  memw [P1.t];        // a NET holder
  logic memu [PG.u];        // a 4-bit member
  logic mems [PG.s];        // a SIGNED member
  logic memn [PO.n.x];      // NESTED
  logic memm [PO.m];        // after a struct member
  logic memf [PE.f];        // beside an enum member
  logic meme [PE.e];        // an ENUM member
  logic memv [PU.v];        // after a UNION member
  logic memq [mp1::PP.b];   // a QUALIFIED package struct parameter
  logic memmd[P1.t][PG.u];  // TWO dims
  logic memr [PG.u-1:0];    // RANGE form (not this law)
  logic memx [PG.u+1];      // inside an ADD (not this law)
endmodule

interface v1_if #(parameter ts1_t Q1 = 32'h6) ();
  logic imem [Q1.t];
endinterface

module v1_top ();
  // the OVERRIDE face: the elaborated instance's member value is NOT the default
  v1_m #(.P1(32'h9), .PG(12'h0A3)) u_ovr ();
  v1_m u_def ();
  v1_if u_if ();
  localparam ts1_t LP = 32'h7;
  logic lmem [LP.t];        // a LOCALPARAM base
  genvar gi;
  generate
    for (gi = 0; gi < 1; gi++) begin : gb
      logic gmem [LP.t];    // inside a generate block
    end
  endgenerate
endmodule
