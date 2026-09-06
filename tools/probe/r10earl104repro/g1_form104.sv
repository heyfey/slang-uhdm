// r10earl104 g1 -- THE ORIGIN GRID.  MEASUREMENT ONLY.
// Surelog mints the folded constant's int_typespec in exactly ONE arm of
// ExprEval::reduceExpr (`case vpiMultiConcatOp`, "// Word size"); every other
// fold -- a plain concat, a cast, an arithmetic reduction, a bare parameter
// substitution -- builds its constant with NO typespec and takes whatever
// DesignElaboration::collectParams_ stamps.  This arm crosses the ORIGIN of the
// fold against ONE declared type (`logic [W-1:0]`, the head's own) with NO
// reader anywhere, so the mint is what should reach the database whenever the
// origin is a replication and nothing else should move.
package pk104;
  parameter int NP = 8;
endpackage

module g1_form104(input logic ext, output logic o);
  m_a1 u_a1(); m_a2 u_a2(); m_a3 u_a3(); m_a4 u_a4(); m_a5 u_a5(); m_a6 u_a6();
  m_a7 u_a7(); m_a8 u_a8(); m_a9 u_a9(); m_aa u_aa(); m_ab u_ab(); m_ac u_ac();
  assign o = ext;
endmodule

module m_a1();  localparam logic [3:0] X = {4{1'b1}};                 endmodule
module m_a2();  localparam int NM = 4;
                localparam logic [NM-1:0] X = {NM{1'b1}};             endmodule
module m_a3();  localparam logic [pk104::NP-1:0] X = {pk104::NP{1'b1}}; endmodule
module m_a4();  localparam int NM = 3;
                localparam logic [NM+1-1:0] X = {(NM+1){1'b1}};       endmodule
module m_a5();  localparam logic [7:0] X = {2{4'hA}};                 endmodule
module m_a6();  localparam logic [5:0] X = {2{{3{1'b1}}}};            endmodule
module m_a7();  localparam logic [7:0] X = {4'hA, 4'h5};              endmodule
module m_a8();  localparam int NM = 4;
                localparam logic [7:0] X = NM * 2;                    endmodule
module m_a9();  localparam int NM = 4;
                localparam logic [7:0] X = 8'(NM);                    endmodule
module m_aa();  localparam int NM = 4;
                localparam logic [7:0] X = NM;                        endmodule
module m_ab();  localparam logic [7:0] X = '0;                        endmodule
module m_ac();  localparam logic [7:0] X = {2{{2'b10, 2'b01}}};       endmodule
