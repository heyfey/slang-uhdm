package pk1_82;
  localparam int          PI  = 8;
  localparam integer      PG  = 8;
  localparam byte         PB  = 8;
  localparam shortint     PS  = 8;
  localparam longint      PL  = 8;
  localparam bit [3:0]    PV  = 4'h7;
  localparam logic [7:0]  PW  = 8;
  localparam              PU  = 8;
  localparam int unsigned PIU = 8;
  localparam bit signed [7:0] PSV = 8;
  localparam int          PX  = 4 + 4;   // expression initializer
  localparam int          PH  = 8'd8;    // based initializer
endpackage

module m1_82 import pk1_82::*; (input logic clk, output logic [63:0] o);
  typedef struct packed { logic [3:0] a; } mr_t;
  mr_t [PI :0] vI;
  mr_t [PG :0] vG;
  mr_t [PB :0] vB;
  mr_t [PS :0] vS;
  mr_t [PL :0] vL;
  mr_t [PV :0] vV;
  mr_t [PW :0] vW;
  mr_t [PU :0] vU;
  mr_t [PIU:0] vIU;
  mr_t [PSV:0] vSV;
  mr_t [PX :0] vX;
  mr_t [PH :0] vH;
  assign o = {vI[0].a, vG[0].a, vB[0].a, vS[0].a, vL[0].a, vV[0].a,
              vW[0].a, vU[0].a, vIU[0].a, vSV[0].a, vX[0].a, vH[0].a,
              16'b0} ^ {64{clk}};
endmodule
