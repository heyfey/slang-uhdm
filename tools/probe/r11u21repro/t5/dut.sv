// t5 — MEMBER TYPESPEC KINDS and WIDTH MISMATCH against the reading Lhs.
package pk;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  typedef struct packed {
    int unsigned iu;      // 32, unsigned int
    int          is;      // 32, SIGNED int
    logic [7:0]  l8;      // 8
    logic [39:0] l40;     // 40
    byte         by;      // 8
    bit          b1;      // 1
    e_t          en;      // 2
  } k_t;
  function automatic k_t mk();
    k_t c;
    c.iu  = 3;
    c.is  = -5;
    c.l8  = 8'hA5;
    c.l40 = 40'h00_0000_00FF;
    c.by  = 8'h7F;
    c.b1  = 1'b1;
    c.en  = E2;
    return c;
  endfunction
  localparam k_t K = mk();
endpackage

module dut #(
    parameter pk::k_t K = pk::K
) (output logic o);
  localparam int          W_IU  = K.iu;    // int   <- int unsigned (32/32)
  localparam int          W_IS  = K.is;    // int   <- int signed   (32/32)
  localparam int          W_L8  = K.l8;    // int   <- logic [7:0]  (32/8)
  localparam int          W_L40 = K.l40;   // int   <- logic [39:0] (32/40)
  localparam int          W_BY  = K.by;    // int   <- byte         (32/8)
  localparam int          W_B1  = K.b1;    // int   <- bit          (32/1)
  localparam int          W_EN  = K.en;    // int   <- enum         (32/2)
  localparam byte         N_L40 = K.l40;   // byte  <- logic [39:0] (8/40)
  localparam logic [15:0] V_L40 = K.l40;   // l[15:0] <- logic[39:0](16/40)
  localparam logic [63:0] V_IU  = K.iu;    // l[63:0] <- int unsigned(64/32)
  assign o = ^{W_IU[0], W_IS[0], W_L8[0], W_L40[0], W_BY[0], W_B1[0],
               W_EN[0], N_L40[0], V_L40[0], V_IU[0]};
endmodule
