// r11u66 arm g7 — THE DISCRIMINATING HALF OF THE TABLE at the elaborated
// pattern-operand site: the `+` arm, which is `vpiUIntConst` UNLESS one reduced
// operand is signed-ish (vpiInt / String / Real / Dec), and the NAME arm, which
// contributes the encoding of the referenced parameter's OWN initializer.
// These are the cells where a "any arithmetic is INT" law would move a RIGHT
// cell to a WRONG one, so every one of them is a fence witness.
package q7;
  localparam int N  = 8;
  localparam int LM = N * 2;      // an INT-answering name
  localparam int LA = N + 1;      // a UINT-answering name
  localparam int LH = 32'h28;     // a based-HEX name
  localparam int LD = 32'd40;     // a based-DECIMAL name
  localparam int LC = LM + 1;     // a chain: INT through an add
  localparam int LZ = LA + 1;     // a chain: UINT through an add
  typedef struct packed {
    logic [31:0] pp;   // 8 + 3          plain + plain      (table: UINT)
    logic [31:0] pm;   // LM + 1         INT-ish + plain    (table: INT)
    logic [31:0] pa;   // LA + 1         UINT-ish + plain   (table: UINT)
    logic [31:0] ph;   // LH + 1         HEX-ish + plain    (table: UINT)
    logic [31:0] pd;   // LD + 1         DEC-ish + plain    (table: INT)
    logic [31:0] pc;   // LC + 1         a two-hop INT chain
    logic [31:0] pz;   // LZ + 1         a two-hop UINT chain
    logic [31:0] ps;   // N - 1 + 2      a subtract UNDER an add
    logic [31:0] pl;   // (N + 1) << 1   an add UNDER a shift (table: UINT)
    logic [31:0] px;   // (N - 1) << 1   a subtract UNDER a shift (table: UINT)
    logic [31:0] py;   // (N - 1) + 0    a subtract UNDER an add (table: INT)
    logic [31:0] pn;   // N              a bare NAME (not this site)
    logic [31:0] pv;   // $clog2(N) + 1  a system call UNDER an add
    logic [31:0] pw;   // $signed(N) + 1
  } c7_t;
  localparam c7_t L7 = '{pp: 8 + 3, pm: LM + 1, pa: LA + 1, ph: LH + 1,
                         pd: LD + 1, pc: LC + 1, pz: LZ + 1, ps: N - 1 + 2,
                         pl: (N + 1) << 1, px: (N - 1) << 1, py: (N - 1) + 0,
                         pn: N, pv: $clog2(N) + 1, pw: $signed(N) + 1};
endpackage
module g7_add66 #(parameter q7::c7_t C = q7::L7)
                (output logic [31:0] o01, output logic [31:0] o02,
                 output logic [31:0] o03, output logic [31:0] o04,
                 output logic [31:0] o05, output logic [31:0] o06,
                 output logic [31:0] o07, output logic [31:0] o08,
                 output logic [31:0] o09, output logic [31:0] o10,
                 output logic [31:0] o11, output logic [31:0] o12,
                 output logic [31:0] o13, output logic [31:0] o14);
  assign o01 = C.pp; assign o02 = C.pm; assign o03 = C.pa; assign o04 = C.ph;
  assign o05 = C.pd; assign o06 = C.pc; assign o07 = C.pz; assign o08 = C.ps;
  assign o09 = C.pl; assign o10 = C.px; assign o11 = C.py; assign o12 = C.pn;
  assign o13 = C.pv; assign o14 = C.pw;
endmodule
