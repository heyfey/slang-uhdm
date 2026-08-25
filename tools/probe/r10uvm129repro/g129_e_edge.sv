// r10uvm129 grid E — the EDGE forms of a declarator array's written base type:
// implicit signing, the `var` keyword, package-scoped and class-scoped names,
// a typedef of a typedef, and a packed dimension written on the base type.
// MEASUREMENT ONLY.
package pk129e;
   typedef int            deepBase129_t;
   typedef deepBase129_t  deepChain129_t;                 // typedef of typedef
   typedef enum { PORT129, STARB129 } sideMark129_e;
   typedef sideMark129_e  sideAlias129_e;                 // alias of an enum
   typedef byte unsigned  ubyteName129_t;
endpackage

module top129e;
   import pk129e::*;

   class Rigging129;
      typedef enum { FORE129, AFT129 } deckSpot129_e;
      typedef int  deckTally129_t;
      task haul129();
         var signed [3:0]   sgnImplicit129 [2];
         var int            varInt129 [3];
         var logic [1:0]    varLogic129 [4];
         pk129e::deepBase129_t  scopedInt129 [5];
         pk129e::deepChain129_t chainInt129 [6];
         pk129e::sideAlias129_e aliasMood129 [7];
         pk129e::ubyteName129_t scopedUbyte129 [8];
         deckSpot129_e      innerMood129 [9];
         deckTally129_t     innerTally129 [10];
         Rigging129::deckSpot129_e qualMood129 [11];
         logic signed [7:0] sgnVector129 [13];
         enum { RAISE129, LOWER129 } inlineMood129 [14];
         struct packed { logic [3:0] bore; } inlineBore129 [15];
         logic unsigned [3:0] unsVector129 [16];
         int unsigned       unsTally129 [17];
         event              bellRing129 [18];
         sgnImplicit129[0] = 4'sd1;
         varInt129[0] = 1;
         varLogic129[0] = 2'b1;
         scopedInt129[0] = 1;
         chainInt129[0] = 1;
         aliasMood129[0] = PORT129;
         scopedUbyte129[0] = 8'd1;
         innerMood129[0] = FORE129;
         innerTally129[0] = 1;
         qualMood129[0] = AFT129;
         sgnVector129[0] = 8'sd1;
         inlineMood129[0] = RAISE129;
         inlineBore129[0].bore = 4'h1;
         unsVector129[0] = 4'h1;
         unsTally129[0] = 1;
      endtask
   endclass

   Rigging129 deckHand129;
   initial begin
      deckHand129 = new();
      deckHand129.haul129();
   end
endmodule
