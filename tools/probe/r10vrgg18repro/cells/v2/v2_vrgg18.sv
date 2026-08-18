// r10vrgg18 grid V2 — the TYPE ZOO on the same carrier: enum, typedef'd
// vector, packed struct, unpacked array, real, string, X/Z, based literals,
// casts, a package-homed parameter reference and a >64-bit declared width.
package v2_pkg;
  typedef logic [11:0] tw_t;
  typedef enum logic [2:0] { E0 = 3'd0, E4 = 3'd4, E7 = 3'd7 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sp_t;
  localparam tw_t PW12 = 12'hC0F;
endpackage

module v2_vrgg18;
  import v2_pkg::*;
  genvar g;
  generate
    for (g = 0; g < 2; g++) begin : gz
      localparam tw_t        TW  = 12'hC00 + 12'(g);
      localparam e_t         EN  = E4;
      localparam sp_t        SP  = {4'hC, 4'h3};
      localparam bit [7:0]   XZ  = 8'b1010_10xz;
      localparam bit [7:0]   HX  = 8'hAB;
      localparam bit [7:0]   OC  = 8'o253;
      localparam bit [7:0]   BN  = 8'b1010_1011;
      localparam real        RR  = -2.5;
      localparam string      ST  = "zz";
      localparam bit [7:0]   AR [0:1] = '{8'hC0, 8'h01};
      localparam bit [65:0]  W66 = 66'h3_0000_0000_0000_0001 + 66'(g);
      localparam bit [7:0]   CST = 8'(signed'(-8'sd64)) + 8'(g);
      localparam bit [7:0]   PKG = PW12[7:0] + 8'(g);
      if (TW == 0 && EN == E0 && SP == 0 && XZ == 0 && HX == OC && BN == 0 &&
          RR == 0.0 && ST == "" && AR[0] == 0 && W66 == 0 && CST == 0 &&
          PKG == 0) begin : gu
        wire w;
      end
    end
  endgenerate
endmodule
