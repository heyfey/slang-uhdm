// r10earl97 g1 -- KIND GRID.  One module-body localparam per integer kind,
// each with a COMPUTED default (so Surelog cannot fold it at definition
// compile -- the distinguisher § castTgtDefaultIsLiteral) and each used as a
// BARE `P'(x)` cast width.  Golden REUSES the DECLARATION typespec as the cast
// target (CompileType.cpp:756-780), so whatever VpiSigned
// compileBuiltinTypespec put on the declaration is what the cast site carries.
module top1k97;
  logic [31:0] o;
  sub1k97 #(.InW(8)) u_s(.o(o));
endmodule

module sub1k97 #(parameter int InW = 32) (output logic [31:0] o);
  logic [3:0] m;
  localparam int              K_INT   = $clog2(InW + 1);
  localparam int unsigned     K_INTU  = $clog2(InW + 2);
  localparam integer          K_IGR   = $clog2(InW + 3);
  localparam integer unsigned K_IGRU  = $clog2(InW + 4);
  localparam shortint         K_SI    = $clog2(InW + 5);
  localparam longint          K_LI    = $clog2(InW + 6);
  localparam byte             K_BY    = $clog2(InW + 7);
  localparam time             K_TM    = $clog2(InW + 8);
  localparam bit [7:0]        K_BIT   = $clog2(InW + 9);
  localparam logic signed [7:0] K_LGS = $clog2(InW + 10);
  assign o = 32'(K_INT'(m)) + 32'(K_INTU'(m)) + 32'(K_IGR'(m)) + 32'(K_IGRU'(m))
           + 32'(K_SI'(m))  + 32'(K_LI'(m))   + 32'(K_BY'(m))  + 32'(K_TM'(m))
           + 32'(K_BIT'(m)) + 32'(K_LGS'(m));
endmodule
