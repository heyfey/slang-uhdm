// r10earl33 arm 2 — THE PARAMETER AXIS, held at the DEF-VIEW GEN-CA position.
//
// § fcArgPkgParamValueFolds32's discriminator is the PARAMETER'S OWN
// INITIALISER (a2_type / a5_init measured it in a module cont-assign).  This
// arm re-measures the same axis one container in, because the def-view
// generate cont-assign is emitted from SYNTAX, not from the bound AST, and a
// syntax-side arm can only inherit that discriminator if golden agrees.
//
// n2/n3/n4 are the three NON-REDUCING shapes; n13 is the FuncStructVal cell
// (a packed struct with a PATTERN init) that cost r10earl32 a regression.
package q33;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;
  typedef logic [7:0] byte_t;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;

  localparam logic [11:0] N1  = 12'h380;              // literal
  localparam logic [7:0]  N2  = {4'h1, 4'h2};         // CONCAT
  localparam logic [7:0]  N3  = {2{4'h3}};            // REPLICATION
  localparam logic [7:0]  N4  = 8'({4'h1, 4'h2});     // CAST of a concat
  localparam logic [7:0]  N5  = 8'h1 + 8'h2;          // ARITHMETIC
  localparam logic [1:0][3:0] N6 = 8'hAB;             // MULTI-dim, literal
  localparam logic [1:0][3:0] N7 = '{4'h1, 4'h2};     // MULTI-dim, PATTERN
  localparam logic [7:0]  N8 [2] = '{8'h1, 8'h2};     // UNPACKED array
  localparam int          N9  = 3;                    // int
  localparam              N10 = 7;                    // UNTYPED
  localparam logic [71:0] N11 = 72'h1;                // > 64 bits
  localparam byte_t       N12 = 8'h5;                 // TYPEDEF'd
  localparam e_t          N13 = E1;                   // ENUM-typed
  localparam ps_t         N14 = '{a: 4'h1, b: 4'h2};  // packed struct, PATTERN
  localparam logic [7:0]  N15 = 8'hXZ;                // UNKNOWN bits
  localparam string       N16 = "hi";                 // STRING
  localparam real         N17 = 1.5;                  // REAL
  localparam logic signed [7:0] N18 = -8'sd3;         // SIGNED
endpackage

module n33 (output logic [31:0] y);
  function automatic logic [31:0] mf (logic [11:0] v);      return {v, 20'h0}; endfunction
  function automatic logic [31:0] mb (logic [7:0]  v);      return {v, 24'h0}; endfunction
  function automatic logic [31:0] mw (logic [71:0] v);      return v[31:0];    endfunction
  function automatic logic [31:0] mi (int v);               return v;          endfunction
  function automatic logic [31:0] mp (q33::ps_t v);         return {v, 24'h0}; endfunction
  function automatic logic [31:0] me (q33::e_t v);          return {30'h0, v}; endfunction
  function automatic logic [31:0] ma (logic [7:0] v [2]);   return {v[0], 24'h0}; endfunction
  function automatic logic [31:0] ms (string v);            return v.len();    endfunction
  function automatic logic [31:0] mr (real v);              return int'(v);    endfunction

  logic [31:0] z;
  for (genvar gi = 0; gi < 2; gi++) begin : gn
    logic [31:0] w1, w2, w3, w4, w5, w6, w7, w8, w9, w10,
                 w11, w12, w13, w14, w15, w16, w17, w18;
    assign w1  = mf(q33::N1);
    assign w2  = mb(q33::N2);
    assign w3  = mb(q33::N3);
    assign w4  = mb(q33::N4);
    assign w5  = mb(q33::N5);
    assign w6  = mb(q33::N6);
    assign w7  = mb(q33::N7);
    assign w8  = ma(q33::N8);
    assign w9  = mi(q33::N9);
    assign w10 = mi(q33::N10);
    assign w11 = mw(q33::N11);
    assign w12 = mb(q33::N12);
    assign w13 = me(q33::N13);
    assign w14 = mp(q33::N14);
    assign w15 = mb(q33::N15);
    assign w16 = ms(q33::N16);
    assign w17 = mr(q33::N17);
    assign w18 = mb(q33::N18);
  end
  assign z = gn[0].w1  ^ gn[0].w2  ^ gn[0].w3  ^ gn[0].w4  ^ gn[0].w5  ^
             gn[0].w6  ^ gn[0].w7  ^ gn[0].w8  ^ gn[0].w9  ^ gn[0].w10 ^
             gn[0].w11 ^ gn[0].w12 ^ gn[0].w13 ^ gn[0].w14 ^ gn[0].w15 ^
             gn[0].w16 ^ gn[0].w17 ^ gn[0].w18;
  assign y = z;
endmodule

module n33top;
  logic [31:0] a;
  n33 u1 (.y(a));
endmodule
