// r10earl81 arm g2 — the ENCODING axis of the ELAB port High_conn bit-select
// index fold, plus the fences.  Every cell is the SAME position (a port
// High_conn bit-select index); only what the index NAMES changes.
// MEASUREMENT ONLY.
module leaf2_81 (input logic ib, output logic o);
  assign o = ib;
endmodule

function automatic logic uf81(input logic [15:0] a);
  return ^a;
endfunction

module enc81 #(
  parameter int unsigned  DBARE = 1,      // overridden with a BARE DECIMAL
  parameter int unsigned  DEXPR = 1,      // overridden with an EXPRESSION
  parameter int unsigned  DPAR  = 1,      // overridden with a PARENTHESISED bare
  parameter bit [3:0]     BHEX  = 4'h1,   // overridden with 4'h5
  parameter bit [3:0]     BBIN  = 4'b0001,// overridden with 4'b0110
  parameter bit [7:0]     BOCT  = 8'o1,   // overridden with 8'o7
  parameter int unsigned  BDEC  = 1,      // overridden with 8'd6
  parameter int unsigned  NOV32 = 7,      // never overridden, int unsigned
  parameter bit [3:0]     NOVH  = 4'h3,   // never overridden, based default
  parameter               NOVU  = 5,      // never overridden, UNTYPED default
  parameter int           NOVI  = 4,      // never overridden, SIGNED int
  parameter bit [3:0]     OVTRUNC = 4'h1, // overridden with a bare decimal 20
                                          // -- WIDER than the formal
  parameter bit [3:0]     OVDEC = 4'h1,   // overridden with a bare decimal 5
  parameter               OVIMP = 1,      // UNTYPED, overridden bare decimal 9
  parameter integer       NOVG  = 6,      // never overridden, SIGNED integer
  parameter byte          NOVB  = 3,      // never overridden, SIGNED byte
  parameter signed [7:0]  NOVSB = 8'sd3,  // never overridden, SIGNED packed
  parameter logic [7:0]   NOVLG = 8'd2    // never overridden, logic vector
) (
  input  logic [15:0] w,
  output logic [15:0] y
);
  localparam int unsigned LPI  = 6;      // module localparam, int unsigned
  localparam bit [3:0]    LPB  = 4'h2;   // module localparam, based
  localparam              LPU  = 3;      // module localparam, untyped
  localparam int unsigned LPE  = DBARE + 1;  // derived from an overridden param

  leaf2_81 uD (.ib(w[DBARE]), .o(y[0]));
  leaf2_81 uE (.ib(w[DEXPR]), .o(y[1]));
  leaf2_81 uP (.ib(w[DPAR ]), .o(y[2]));
  leaf2_81 uH (.ib(w[BHEX ]), .o(y[3]));
  leaf2_81 uB (.ib(w[BBIN ]), .o(y[4]));
  leaf2_81 uO (.ib(w[BOCT ]), .o(y[5]));
  leaf2_81 uC (.ib(w[BDEC ]), .o(y[6]));
  leaf2_81 uN (.ib(w[NOV32]), .o(y[7]));
  leaf2_81 uG (.ib(w[NOVH ]), .o(y[8]));
  leaf2_81 uU (.ib(w[NOVU ]), .o(y[9]));
  leaf2_81 uS (.ib(w[NOVI ]), .o(y[10]));
  leaf2_81 uL (.ib(w[LPI  ]), .o(y[11]));
  leaf2_81 uM (.ib(w[LPB  ]), .o(y[12]));
  leaf2_81 uT (.ib(w[LPU  ]), .o(y[13]));
  leaf2_81 uR (.ib(w[LPE  ]), .o(y[14]));
  // The OVERRIDDEN-actual WIDTH controls: a bare decimal actual is stored
  // UNMASKED at Surelog's unsized 64 whatever the formal's own width is.
  leaf2_81 uW (.ib(w[OVTRUNC]), .o());
  leaf2_81 uX (.ib(w[OVDEC  ]), .o());
  leaf2_81 uY (.ib(w[OVIMP  ]), .o());
  // The SIGNEDNESS axis of the NON-overridden fold (uS is the first witness:
  // golden stamps a ref_typespec on that one and on no other).
  localparam int          LPS  = 7;      // module localparam, SIGNED int
  leaf2_81 uZa (.ib(w[NOVG ]), .o());
  leaf2_81 uZb (.ib(w[NOVB ]), .o());
  leaf2_81 uZc (.ib(w[NOVSB]), .o());
  leaf2_81 uZd (.ib(w[NOVLG]), .o());
  leaf2_81 uZe (.ib(w[LPS  ]), .o());

  // FENCE (d): the same read inside a USER call's argument list, and inside a
  // SYSTEM call's, in the very same High_conn.
  leaf2_81 uFa (.ib(uf81({15'b0, w[DBARE]})),        .o(y[15]));
  leaf2_81 uFb (.ib(^$signed({15'b0, w[DBARE]})),    .o());

  // BODY-POSITION TWINS (the control: the same index, another home).
  logic tw0, tw1, tw2;
  assign tw0 = w[DBARE];
  always_comb tw1 = w[DBARE];
  initial      tw2 = w[DBARE];
endmodule

module top2_81 (input logic [15:0] w, output logic [15:0] ya, yb);
  localparam int unsigned SRC = 2;
  enc81 #(.DBARE(2), .DEXPR(1+1), .DPAR((2)), .BHEX(4'h5), .BBIN(4'b0110),
          .BOCT(8'o7), .BDEC(8'd6), .OVTRUNC(20), .OVDEC(5), .OVIMP(9))
                                                          ia (.w(w), .y(ya));
  enc81 #(.DBARE(3), .DEXPR(SRC),  .DPAR((3)), .BHEX(4'h5), .BBIN(4'b0110),
          .BOCT(8'o7), .BDEC(8'd6), .OVTRUNC(20), .OVDEC(5), .OVIMP(9))
                                                          ib (.w(w), .y(yb));
endmodule
