// r10earl104 g2 -- THE DECLARED-TYPE GRID.  MEASUREMENT ONLY.
// ONE origin (a replication) x the declared types the emitter's replication-fold
// arm dispatches on: a packed vector (the PackedArrayType branch this law
// edits), a PredefinedIntegerType (its own branch, untouched), a scalar, a
// typedef, an unpacked-dimension-free multidim, a signed vector, a non-zero-
// based single bit, and NO declared type at all (§ replFoldTs9).  NO reader.
typedef logic [7:0] t8_104;
module g2_type104(input logic ext, output logic o);
  m_b1 u_b1(); m_b2 u_b2(); m_b3 u_b3(); m_b4 u_b4(); m_b5 u_b5(); m_b6 u_b6();
  m_b7 u_b7(); m_b8 u_b8(); m_b9 u_b9(); m_ba u_ba(); m_bb u_bb();
  assign o = ext;
endmodule
module m_b1(); localparam logic [7:0]        X = {8{1'b1}};  endmodule
module m_b2(); localparam logic [0:0]        X = {1{1'b1}};  endmodule
module m_b3(); localparam logic              X = {1{1'b1}};  endmodule
module m_b4(); localparam bit   [7:0]        X = {8{1'b1}};  endmodule
module m_b5(); localparam int                X = {8{1'b1}};  endmodule
module m_b6(); localparam integer            X = {8{1'b1}};  endmodule
module m_b7(); localparam byte               X = {8{1'b1}};  endmodule
module m_b8(); localparam t8_104             X = {8{1'b1}};  endmodule
module m_b9(); localparam                    X = {8{1'b1}};  endmodule
module m_ba(); localparam logic signed [7:0] X = {8{1'b1}};  endmodule
module m_bb(); localparam logic [3:3]        X = {1{1'b1}};  endmodule
