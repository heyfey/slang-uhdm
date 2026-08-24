// v82 adversarial arm V3 — THE SECOND PATCHED CALL SITE: the packed struct
// array NET (`emitPackedStructArrayNet`), which the pass's own grid never
// exercises (its "packed-net" column is a plain `logic` vector).  Package
// referents at every declared type + a MODULE localparam + an UNTYPED one +
// a BASED-literal one, each on a NET and on a VAR.  MEASUREMENT ONLY.
package pkv3_82;
  localparam int          PI = 8;
  localparam byte         PB = 8;
  localparam shortint     PS = 8;
  localparam longint      PL = 8;
  localparam bit [3:0]    PV = 4'h7;
  localparam              PU = 8;
  localparam int          PD = 8'd8;
  localparam int          PE = 4 + 4;
  localparam int          PM = PI - 1;
endpackage

typedef struct packed { logic [3:0] a; logic [3:0] b; } mv3_t;

module top_v3_82 import pkv3_82::*; (input logic clk, output logic o);
  localparam int MLP = 8;
  localparam     MLU = 8;
  wire  mv3_t [PI:0]  w_PI;
  wire  mv3_t [PB:0]  w_PB;
  wire  mv3_t [PS:0]  w_PS;
  wire  mv3_t [PL:0]  w_PL;
  wire  mv3_t [PV:0]  w_PV;
  wire  mv3_t [PU:0]  w_PU;
  wire  mv3_t [PD:0]  w_PD;
  wire  mv3_t [PE:0]  w_PE;
  wire  mv3_t [PM:0]  w_PM;
  wire  mv3_t [MLP:0] w_MLP;
  wire  mv3_t [MLU:0] w_MLU;
  wire  mv3_t [pkv3_82::PI:0] w_QI;
  var   mv3_t [PI:0]  v_PI;
  var   mv3_t [PB:0]  v_PB;
  var   mv3_t [PV:0]  v_PV;
  var   mv3_t [PU:0]  v_PU;
  var   mv3_t [PD:0]  v_PD;
  var   mv3_t [PM:0]  v_PM;
  var   mv3_t [MLP:0] v_MLP;
  assign o = clk ^ w_PI[0].a[0] ^ w_PB[0].a[0] ^ w_PS[0].a[0] ^ w_PL[0].a[0]
             ^ w_PV[0].a[0] ^ w_PU[0].a[0] ^ w_PD[0].a[0] ^ w_PE[0].a[0]
             ^ w_PM[0].a[0] ^ w_MLP[0].a[0] ^ w_MLU[0].a[0] ^ w_QI[0].a[0]
             ^ v_PI[0].a[0] ^ v_PB[0].a[0] ^ v_PV[0].a[0] ^ v_PU[0].a[0]
             ^ v_PD[0].a[0] ^ v_PM[0].a[0] ^ v_MLP[0].a[0];
endmodule
