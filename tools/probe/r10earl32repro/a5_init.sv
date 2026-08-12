// r10earl32 arm 5 — THE INITIALISER-SHAPE AXIS, at the edges.
//
// a2_type.sv established that the discriminator is the parameter's own
// INITIALISER, not its type.  This arm holds the position fixed (a module-local
// function-call argument in a cont_assign) and walks the edges of that
// predicate — the two CARVE-OUTS `paramDefRhsIsOp` already carries
// (§ castDefaultPatternConcat and the struct/union exception), the cast-wrapped
// concat it deliberately looks through, transitivity through a second
// parameter, and the value kinds the fold path cannot express at all.
package i32;
  localparam logic [11:0] I1  = 12'h380;                 // literal  -> FOLD
  localparam logic [7:0]  I2  = {4'h1, 4'h2};            // concat   -> ref
  localparam logic [7:0]  I3  = {2{4'h3}};               // REPLICATION
  localparam logic [7:0]  I4  = 8'({4'h1, 4'h2});        // CAST of a concat
  localparam logic [7:0]  I5  = I2;                      // reads a concat param
  localparam logic [7:0]  I6  = I1[7:0];                 // a SELECT of a param
  localparam int          I7  = int'{default: 3};        // castDefaultIntPattern
  localparam logic [7:0]  I8  = f32(8'h2);               // a FUNCTION-CALL init
  localparam logic [7:0]  I9  = 8'hXZ;                   // UNKNOWN bits
  localparam string       I10 = "hi";                    // STRING
  localparam real         I11 = 1.5;                     // REAL

  typedef struct packed { logic [3:0] a; logic [3:0] b; } sp_t;
  localparam sp_t         I12 = 8'h12;                   // packed struct, LITERAL
  localparam sp_t         I13 = '{a: 4'h1, b: 4'h2};     // packed struct, pattern

  function automatic logic [7:0] f32(logic [7:0] v); return v + 8'h1; endfunction
endpackage

module i32a (output logic [31:0] o);
  function automatic logic [31:0] f8 (logic [7:0]  v); return {v, 24'h0}; endfunction
  function automatic logic [31:0] f12(logic [11:0] v); return {v, 20'h0}; endfunction
  function automatic logic [31:0] fi (int          v); return v;          endfunction
  function automatic logic [31:0] fs (string       v); return 32'(v.len()); endfunction
  function automatic logic [31:0] fr (real         v); return 32'(int'(v)); endfunction
  function automatic logic [31:0] fp (i32::sp_t    v); return {v, 24'h0}; endfunction

  assign o = f12(i32::I1)                                // n1  literal
           ^ f8 (i32::I2)                                // n2  concat
           ^ f8 (i32::I3)                                // n3  replication
           ^ f8 (i32::I4)                                // n4  cast-of-concat
           ^ f8 (i32::I5)                                // n5  reads a concat param
           ^ f8 (i32::I6)                                // n6  select of a param
           ^ fi (i32::I7)                                // n7  int'{default:3}
           ^ f8 (i32::I8)                                // n8  function-call init
           ^ f8 (i32::I9)                                // n9  UNKNOWN bits
           ^ fs (i32::I10)                               // n10 string
           ^ fr (i32::I11)                               // n11 real
           ^ fp (i32::I12)                               // n12 struct, literal
           ^ fp (i32::I13);                              // n13 struct, pattern
endmodule

module i32top;
  logic [31:0] o;
  i32a u (.o(o));
endmodule
