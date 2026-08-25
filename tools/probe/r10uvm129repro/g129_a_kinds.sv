// r10uvm129 grid A — the ELEMENT VARIABLE of a fixed-size declarator array,
// one cell per WRITTEN element-type form.  Every cell is a BLOCK-ITEM local of
// the same class task; the array sizes are all different and the declaration
// order is deliberately NOT the emitter's dispatch order, so no cell can agree
// by accident.  MEASUREMENT ONLY.
package pk129a;

   typedef enum { RUBY129, JADE129, ONYX129 } gemcut129_e;          // int base
   typedef enum bit [1:0] { LOWB129, MIDB129 } bandsel129_e;        // 2-state
   typedef enum byte { TICK129, TOCK129 } clockface129_e;           // signed 8
   typedef enum byte unsigned { WARM129, COOL129 } thermal129_e;
   typedef enum shortint { NORTH129, SOUTH129 } compass129_e;
   typedef enum int unsigned { OPEN129, SHUT129 } valvepos129_e;
   typedef enum logic [2:0] { IDLE129, BUSY129 } enginemode129_e;

   typedef int         tallycount129_t;
   typedef byte        rasterbyte129_t;
   typedef shortint    offsetword129_t;
   typedef logic [3:0] nibblebus129_t;
   typedef string      captiontext129_t;
   typedef struct packed { logic [2:0] hue; logic sat; } paintmix129_t;
   typedef struct packed signed { logic [4:0] mag; } tiltangle129_t;
   typedef struct { int wid; string cap; } looseframe129_t;

   class Anvil129;
      int weight129;
   endclass

   class Forge129;
      task heat129();
         string       plaqueText129 [7];
         real         furnaceTemp129 [3];
         bit signed [7:0] cinderMask129 [11];
         gemcut129_e  facetPlan129 [2];
         longint      ledgerBig129 [5];
         nibblebus129_t wireTap129 [13];
         time         stopWatch129 [4];
         byte unsigned tokenCount129 [6];
         logic        rawStrobe129 [17];
         valvepos129_e sluiceState129 [8];
         integer      scoreBoard129 [9];
         captiontext129_t bannerLine129 [19];
         logic signed [3:0] tiltRead129 [10];
         clockface129_e beatPhase129 [12];
         shortint     stepDelta129 [14];
         Anvil129     hammerSet129 [15];
         rasterbyte129_t pixelRow129 [16];
         bandsel129_e chanPick129 [18];
         int unsigned quotaLeft129 [20];
         paintmix129_t swatchGrid129 [21];
         byte         crumbTrail129 [22];
         thermal129_e ductFlow129 [23];
         tallycount129_t auditTick129 [24];
         bit          flagPile129 [25];
         compass129_e vaneTurn129 [26];
         tiltangle129_t leanMeter129 [27];
         offsetword129_t skewPair129 [28];
         enginemode129_e drivePlan129 [29];
         int          plainCount129 [30];
         looseframe129_t crateRow129 [31];
         shortreal    airDensity129 [32];
         plaqueText129[0] = "x";
         furnaceTemp129[0] = 1.0;
         cinderMask129[0] = 8'sd1;
         facetPlan129[0] = RUBY129;
         ledgerBig129[0] = 1;
         wireTap129[0] = 4'h1;
         stopWatch129[0] = 1;
         tokenCount129[0] = 8'd1;
         rawStrobe129[0] = 1'b1;
         sluiceState129[0] = OPEN129;
         scoreBoard129[0] = 1;
         bannerLine129[0] = "y";
         tiltRead129[0] = 4'sd1;
         beatPhase129[0] = TICK129;
         stepDelta129[0] = 1;
         hammerSet129[0] = null;
         pixelRow129[0] = 8'd1;
         chanPick129[0] = LOWB129;
         quotaLeft129[0] = 1;
         swatchGrid129[0] = '0;
         crumbTrail129[0] = 8'd1;
         ductFlow129[0] = WARM129;
         auditTick129[0] = 1;
         flagPile129[0] = 1'b1;
         vaneTurn129[0] = NORTH129;
         leanMeter129[0] = '0;
         skewPair129[0] = 1;
         drivePlan129[0] = IDLE129;
         plainCount129[0] = 1;
         crateRow129[0].wid = 1;
         airDensity129[0] = 1.0;
      endtask
   endclass
endpackage

module top129a;
   import pk129a::*;
   Forge129 shopFloor129;
   initial begin
      shopFloor129 = new();
      shopFloor129.heat129();
   end
endmodule
