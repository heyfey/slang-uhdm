// r10v64 ARM 1 — OVERRIDE SOURCE MATRIX for § elabCaPortParamPaCopy64.
// Every override spelling an integral port parameter can receive, read from a
// gen-if cont_assign (the home the law is armed for) and from the module body.
// MEASUREMENT ONLY.
package pv1;
  parameter int unsigned PKGP = 3;
  typedef logic [3:0] nib_t;
  typedef enum logic [2:0] { E0 = 3'd0, E2 = 3'd2, E5 = 3'd5 } e_t;
endpackage

module subV1 #(parameter int unsigned P = 4)
  (input logic c, input logic [7:0] n,
   output [3:0] o1, output [3:0] o2, output [3:0] o3, output [3:0] o4,
   output [3:0] o5, output [3:0] o6);
  localparam int unsigned W = 4;
  assign o1 = c ? P : P;              // module body ternary arms
  assign o2 = W'(P);                  // module body cast
  if (P != 0) begin : g_if
    wire [3:0] q1, q2, q3, q4;
    assign q1 = c ? P : P;            // gen-if ternary arms  <- the law's site
    assign q2 = W'(P);                // gen-if cast
    assign q3 = P + 1;                // gen-if binop
    assign q4 = n[P];                 // gen-if select index
  end
  assign o3 = 4'(P);
  assign o4 = P > 1 ? 4'd1 : 4'd0;
  assign o5 = {2'b00, P[1:0]};
  assign o6 = n[P +: 1];
endmodule

module topV1(input logic c, input logic [7:0] n);
  localparam int         SI  = 1 * 2;      // int expression
  localparam int unsigned SU = 2;          // plain decimal
  localparam bit  [3:0]  SH  = 4'h2;       // hex
  localparam bit  [3:0]  SB  = 4'b0010;    // bin
  localparam bit  [5:0]  SO  = 6'o02;      // octal
  localparam int         SN  = -3;         // negative
  localparam pv1::nib_t  ST  = 4'd2;       // typedef'd
  localparam pv1::e_t    SE  = pv1::E2;    // enum member
  localparam int unsigned SC = SU + SI;    // param-of-param
  wire [3:0] a0,a1,a2,a3,a4,a5;  wire [3:0] b0,b1,b2,b3,b4,b5;
  wire [3:0] c0,c1,c2,c3,c4,c5;  wire [3:0] d0,d1,d2,d3,d4,d5;
  wire [3:0] e0,e1,e2,e3,e4,e5;  wire [3:0] f0,f1,f2,f3,f4,f5;
  wire [3:0] g0,g1,g2,g3,g4,g5;  wire [3:0] h0,h1,h2,h3,h4,h5;
  wire [3:0] i0,i1,i2,i3,i4,i5;  wire [3:0] j0,j1,j2,j3,j4,j5;
  wire [3:0] k0,k1,k2,k3,k4,k5;  wire [3:0] l0,l1,l2,l3,l4,l5;
  wire [3:0] m0,m1,m2,m3,m4,m5;  wire [3:0] p0,p1,p2,p3,p4,p5;
  subV1 #(.P(2))        i_dec  (c,n,a0,a1,a2,a3,a4,a5);
  subV1 #(.P(4'h2))     i_hexl (c,n,b0,b1,b2,b3,b4,b5);
  subV1 #(.P(4'b0010))  i_binl (c,n,c0,c1,c2,c3,c4,c5);
  subV1 #(.P(6'o02))    i_octl (c,n,d0,d1,d2,d3,d4,d5);
  subV1 #(.P(32'd2))    i_szd  (c,n,e0,e1,e2,e3,e4,e5);
  subV1 #(.P(SI))       i_pexp (c,n,f0,f1,f2,f3,f4,f5);
  subV1 #(.P(SH))       i_phex (c,n,g0,g1,g2,g3,g4,g5);
  subV1 #(.P(SB))       i_pbin (c,n,h0,h1,h2,h3,h4,h5);
  subV1 #(.P(SO))       i_poct (c,n,i0,i1,i2,i3,i4,i5);
  subV1 #(.P(ST))       i_ptyp (c,n,j0,j1,j2,j3,j4,j5);
  subV1 #(.P(SE))       i_penu (c,n,k0,k1,k2,k3,k4,k5);
  subV1 #(.P(SC))       i_pofp (c,n,l0,l1,l2,l3,l4,l5);
  subV1 #(.P(pv1::PKGP)) i_ppkg(c,n,m0,m1,m2,m3,m4,m5);
  subV1                 i_dflt (c,n,p0,p1,p2,p3,p4,p5);
endmodule
