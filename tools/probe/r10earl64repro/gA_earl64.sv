// r10earl64 GRID A — the ELAB fold of a PARAMETER READ inside a cont_assign
// expression, keyed by (home, position, override source).
// MEASUREMENT ONLY.
module subA #(
  parameter int unsigned P = 4,
  localparam int unsigned W = 4
) (input logic c, input logic [7:0] n,
   output [3:0] o1, output [3:0] o2, output [3:0] o3, output [3:0] o4,
   output [3:0] o5, output [3:0] o6, output [3:0] o7, output [3:0] o8,
   output [3:0] o9, output [3:0] oa, output [3:0] ob, output [3:0] oc,
   output [3:0] od, output [3:0] oe, output [3:0] of);
  localparam int unsigned LP = P + 1;
  // ---- MODULE BODY home -------------------------------------------------
  assign o1 = c ? P : P;              // ternary arms, bare
  assign o2 = P;                      // bare whole-Rhs
  assign o3 = W'(P);                  // cast root
  assign o4 = {P};                    // concat root
  assign o5 = P + P;                  // binop root
  assign o6 = c ? W'(P) : W'(P);      // cast inside ternary
  assign o7 = c ? {P} : {P};          // concat inside ternary
  assign o8 = (c ? P : P) + 1;        // ternary nested under a binop
  assign o9 = {n, P[0]};              // reduce-blocked concat with a net
  assign oa = c ? LP : LP;            // module LOCALPARAM in ternary arms
  assign ob = n[P];                   // select index
  assign oc = n[P +: 1];              // indexed part select base
  assign od = c ? n[P] : n[P];        // select index inside ternary
  assign oe = c ? P + 1 : P + 1;      // binop inside ternary
  assign of = n & {4{P[0]}};          // replication with a net
  // ---- IF-GENERATE home --------------------------------------------------
  if (P != 0) begin : g_if
    localparam int unsigned GP = P * 2;
    wire [3:0] q1, q2, q3, q4, q5, q6;
    assign q1 = c ? P : P;
    assign q2 = P;
    assign q3 = W'(P);
    assign q4 = c ? W'(P) : W'(P);
    assign q5 = c ? GP : GP;          // gen-LOCAL localparam
    assign q6 = c ? LP : LP;          // module localparam read from gen scope
  end
  // ---- FOR-GENERATE home -------------------------------------------------
  for (genvar i = 0; i < 2; i++) begin : g_for
    localparam int unsigned FP = P + i;
    wire [3:0] r1, r2, r3, r4, r5;
    assign r1 = c ? P : P;
    assign r2 = P;
    assign r3 = W'(P);
    assign r4 = c ? FP : FP;
    assign r5 = c ? P[i] : P[i];
  end
endmodule

module topA(input logic c, input logic [7:0] n);
  localparam int    SX = 1 * 2;       // int expression  -> INT
  localparam bit [3:0] HX = 4'h2;     // hex literal     -> HEX
  localparam bit [3:0] BX = 4'b0010;  // binary literal  -> BIN
  localparam int unsigned UX = 2;     // plain decimal   -> UINT
  wire [3:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,wa,wb,wc,wd,we;
  wire [3:0] x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,xa,xb,xc,xd,xe;
  wire [3:0] y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,ya,yb,yc,yd,ye;
  wire [3:0] z0,z1,z2,z3,z4,z5,z6,z7,z8,z9,za,zb,zc,zd,ze;
  wire [3:0] v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,va,vb,vc,vd,ve;
  wire [3:0] t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,ta,tb,tc,td,te;
  subA #(.P(SX))     i_expr (c,n,w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,wa,wb,wc,wd,we);
  subA #(.P(2))      i_dec  (c,n,x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,xa,xb,xc,xd,xe);
  subA #(.P(HX))     i_hex  (c,n,y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,ya,yb,yc,yd,ye);
  subA #(.P(BX))     i_bin  (c,n,z0,z1,z2,z3,z4,z5,z6,z7,z8,z9,za,zb,zc,zd,ze);
  subA #(.P(4'd2))   i_sized(c,n,v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,va,vb,vc,vd,ve);
  subA              i_deflt (c,n,t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,ta,tb,tc,td,te);
endmodule
