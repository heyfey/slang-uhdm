// r10earl76 arm g2 -- THE ORIGIN / ENCODING GRID.  Every symbol origin and
// every package-parameter INITIALISER SHAPE, read from the FENCED position
// (a for-loop CONDITION inside a gen-scope always_comb) and from the
// unfenced twin one line down (a plain statement), with a module-body row as
// the control.
//
// Question 4 asks what the `enum_const` golden mints carries: the corpus head
// (`parameter int WidthMultiple = DataWidth / BusWidth`) has `INT:2` while
// g1's `parameter int NB = 4` has `UINT:4`, so the value PREFIX is a function
// of the INITIALISER, not of the declared type.  This arm sweeps the shapes.
package g76q;
  parameter int    QA = 7;                 // read QUALIFIED  (g76q::QA)
  parameter int    QX = 9;                 // read via an EXPLICIT single import
  parameter int    QC = 6;                 // read by g76p, cross-package copy
endpackage

package g76p;
  parameter int     NB = 4;                // plain literal
  parameter int     ND = 8 / 2;            // DIVISION  (the corpus head's shape)
  parameter int     NS = 3 + 1;            // ADDITION
  parameter int     NM = 2 * 3;            // MULTIPLICATION
  parameter int     NG = $clog2(16);       // a system function
  parameter int     NX = g76q::QC;         // a cross-package COPY
  parameter         NU = 5;                // IMPLICITLY typed
  parameter bit [7:0] TB = 8'hA5;          // a packed bit vector
  parameter longint NL = 40;               // longint
  parameter int     NR = 9 % 4;            // MODULO
  parameter int     NN = 9 - 4;            // SUBTRACTION
  parameter int     NP = 2 ** 3;           // POWER
  parameter int     NW = (2 * 3) + 1;      // a MULTIPLICATION under an addition
endpackage

module g76orig #(parameter int MP = 3) (input logic clk, output logic [31:0] o);
  import g76p::*;
  import g76q::QX;
  localparam int ML = 5;
  logic [31:0] r [0:13];

  if (MP > 0) begin : gen_o
    localparam int GL = 6;
    always_comb begin
        r[0]  = '0;
        for (int i = 0; i < NB; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < ND; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NS; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NM; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NG; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NX; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NU; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < TB; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NL; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < g76q::QA; i++) r[0] = r[0] + 1;   // QUALIFIED
        for (int i = 0; i < QX; i++) r[0]  = r[0]  + 1;       // EXPLICIT import
        for (int i = 0; i < MP; i++) r[0]  = r[0]  + 1;       // module parameter
        for (int i = 0; i < ML; i++) r[0]  = r[0]  + 1;       // module localparam
        for (int i = 0; i < GL; i++) r[0]  = r[0]  + 1;       // gen-scope localparam
        for (int i = 0; i < NR; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NN; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NP; i++) r[0]  = r[0]  + 1;
        for (int i = 0; i < NW; i++) r[0]  = r[0]  + 1;
        r[1] = NB + ND + NS + NM + NG + NX + NU + NL + g76q::QA + QX
             + MP + ML + GL + NR + NN + NP + NW;               // unfenced twin
    end
  end

  // the GENVAR and a gen-for home, both at DEPTH 1
  for (genvar g = 0; g < 2; g++) begin : gen_v
    always_comb begin
      r[2] = '0;
      for (int i = 0; i < NB; i++)  r[2] = r[2] + 1;   // pkg param, gen-for home
      for (int i = 0; i < g + 2; i++) r[2] = r[2] + 1; // the GENVAR
      for (int i = 0; i < MP; i++)  r[2] = r[2] + 1;   // module parameter
    end
  end

  assign o = r[0] ^ r[1] ^ r[2];
endmodule

module g76origb #(parameter int MP = 3) (input logic clk, output logic [31:0] o);
  import g76p::*;
  import g76q::QX;
  localparam int ML = 5;
  logic [31:0] r [0:1];
  always_comb begin                          // MODULE BODY control: folds
    r[0] = '0;
    for (int i = 0; i < NB; i++) r[0] = r[0] + 1;
    for (int i = 0; i < ND; i++) r[0] = r[0] + 1;
    for (int i = 0; i < g76q::QA; i++) r[0] = r[0] + 1;
    for (int i = 0; i < QX; i++) r[0] = r[0] + 1;
    for (int i = 0; i < MP; i++) r[0] = r[0] + 1;
    for (int i = 0; i < ML; i++) r[0] = r[0] + 1;
    for (int i = 0; i < NM; i++) r[0] = r[0] + 1;
    for (int i = 0; i < TB; i++) r[0] = r[0] + 1;
    r[1] = NB + ND + g76q::QA + QX + MP + ML + NM + TB;
  end
  assign o = r[0] ^ r[1];
endmodule

module g76origtop (input logic clk, output logic [31:0] o1, output logic [31:0] o2);
  g76orig  #(3) u_o (.clk(clk), .o(o1));
  g76origb #(3) u_c (.clk(clk), .o(o2));
endmodule
