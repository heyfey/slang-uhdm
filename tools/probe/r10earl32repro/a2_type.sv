// r10earl32 arm 2 — THE PARAMETER-TYPE x INIT-SHAPE AXIS.
//
// Position held at the witness's (a MODULE-local function-call argument in a
// process, qualified read, no import).  Only the PARAMETER changes.
//
// THIS ARM EXISTS TO SPLIT TWO HYPOTHESES THAT THE CORPUS CANNOT SPLIT.  On
// Earlgrey every folded call-arg parameter (`dm::DataAddr`, `logic [11:0]`,
// literal init) is BOTH one-dimensional AND literal-initialised, and every
// ref-kept one (`prim_cipher_pkg::PRINCE_SBOX4`, `logic [15:0][3:0]`, concat
// init; `aes_sbox_canright_pkg::A2X`, `logic [7:0] [8]`, pattern init) is
// BOTH multi-dimensional AND operation-initialised.  t3/t4 and t2 break the
// correlation deliberately: a MULTI-DIM param with a PLAIN LITERAL init, and a
// ONE-DIM param with a CONCAT init.
package y32;
  localparam logic [11:0]      T1  = 12'h380;                 // 1-dim, literal
  localparam logic [7:0]       T2  = {4'h1, 4'h2};            // 1-dim, CONCAT
  localparam logic [1:0][3:0]  T3  = 8'hAB;                   // 2-dim, LITERAL
  localparam logic [1:0][3:0]  T4  = {4'h1, 4'h2};            // 2-dim, concat
  localparam logic [7:0]       T5  [2] = '{8'h1, 8'h2};       // UNPACKED
  localparam int               T6  = 3;                       // int
  localparam                   T7  = 7;                       // UNTYPED
  localparam logic [7:0]       T8  = 8'h1 + 8'h2;             // 1-dim, EXPRESSION
  localparam logic signed [7:0] T9 = -8'sd3;                  // signed
  localparam logic [1:0][3:0]  T10 = '{4'h1, 4'h2};           // 2-dim, PATTERN
  localparam logic [63:0]      T11 = 64'hDEADBEEFCAFEBABE;    // 1-dim, 64 bits
  localparam logic [71:0]      T12 = 72'h1;                   // 1-dim, >64 bits

  typedef logic [7:0] byte_t;
  localparam byte_t            T13 = 8'h9;                    // TYPEDEF'd type

  typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;
  localparam ps_t              T14 = '{a: 4'h1, b: 4'h2};     // packed STRUCT

  typedef enum logic [3:0] { E0 = 4'h0, E1 = 4'h1 } e_t;
  localparam e_t               T15 = E1;                      // ENUM-typed param
  localparam logic [3:0]       T16 = E1;                      // init FROM an enum
endpackage

module y32a (
  input  logic [2:0]  sz_i,
  output logic [31:0] o
);
  function automatic logic [31:0] f12(logic [11:0] v); return {v, 20'h0}; endfunction
  function automatic logic [31:0] f8 (logic [7:0]  v); return {v, 24'h0}; endfunction
  function automatic logic [31:0] fi (int          v); return v;          endfunction
  function automatic logic [31:0] f64(logic [63:0] v); return v[31:0];    endfunction
  function automatic logic [31:0] f72(logic [71:0] v); return v[31:0];    endfunction
  function automatic logic [31:0] fu (logic [7:0]  v [2]); return {v[0], v[1], 16'h0}; endfunction
  function automatic logic [31:0] fs (y32::ps_t    v); return {v, 24'h0}; endfunction
  function automatic logic [31:0] fe (y32::e_t     v); return {v, 28'h0}; endfunction

  logic [31:0] r [16];
  always_comb begin
    r[0]  = f12(y32::T1);                                     // t1
    r[1]  = f8 (y32::T2);                                     // t2
    r[2]  = f8 (y32::T3);                                     // t3
    r[3]  = f8 (y32::T4);                                     // t4
    r[4]  = fu (y32::T5);                                     // t5
    r[5]  = fi (y32::T6);                                     // t6
    r[6]  = fi (y32::T7);                                     // t7
    r[7]  = f8 (y32::T8);                                     // t8
    r[8]  = f8 (y32::T9);                                     // t9
    r[9]  = f8 (y32::T10);                                    // t10
    r[10] = f64(y32::T11);                                    // t11
    r[11] = f72(y32::T12);                                    // t12
    r[12] = f8 (y32::T13);                                    // t13
    r[13] = fs (y32::T14);                                    // t14
    r[14] = fe (y32::T15);                                    // t15
    r[15] = f8 ({4'h0, y32::T16});                            // t16
  end
  assign o = r[0]^r[1]^r[2]^r[3]^r[4]^r[5]^r[6]^r[7]
           ^ r[8]^r[9]^r[10]^r[11]^r[12]^r[13]^r[14]^r[15];
endmodule

module y32top;
  logic [2:0] sz;
  logic [31:0] o;
  y32a u (.sz_i(sz), .o(o));
endmodule
