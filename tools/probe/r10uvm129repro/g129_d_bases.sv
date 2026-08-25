// r10uvm129 grid D — enum BASE TYPES (signed and unsigned) and 1..3 instances
// of the same typedef, so a per-declaration answer and a per-typedef answer are
// distinguishable.  MEASUREMENT ONLY.
package pk129d;
   typedef enum               { ALFA129, BRAVO129 } plainBase129_e;   // int
   typedef enum int           { CHARL129, DELTA129 } intBase129_e;
   typedef enum int unsigned  { ECHO129, FOXTR129 } uintBase129_e;
   typedef enum byte          { GOLF129, HOTEL129 } byteBase129_e;
   typedef enum byte unsigned { INDIA129, JULIE129 } ubyteBase129_e;
   typedef enum shortint      { KILO129, LIMA129 } shortBase129_e;
   typedef enum longint       { MIKE129, NOVEM129 } longBase129_e;
   typedef enum bit [1:0]     { OSCAR129, PAPA129 } bitBase129_e;
   typedef enum logic [2:0]   { QUEBE129, ROMEO129 } logicBase129_e;
   typedef enum integer       { SIERR129, TANGO129 } integBase129_e;

   class Tally129;
      task run129();
         plainBase129_e  onePlain129 [2];
         plainBase129_e  twoPlain129 [3];
         plainBase129_e  triPlain129 [4];
         intBase129_e    oneInt129 [5];
         intBase129_e    twoInt129 [6];
         uintBase129_e   oneUint129 [7];
         byteBase129_e   oneByte129 [8];
         byteBase129_e   twoByte129 [9];
         ubyteBase129_e  oneUbyte129 [10];
         shortBase129_e  oneShort129 [11];
         longBase129_e   oneLong129 [12];
         bitBase129_e    oneBit129 [13];
         logicBase129_e  oneLogic129 [14];
         integBase129_e  oneInteg129 [15];
         integBase129_e  twoInteg129 [16];
         integBase129_e  triInteg129 [17];
         onePlain129[0] = ALFA129; twoPlain129[0] = BRAVO129; triPlain129[0] = ALFA129;
         oneInt129[0] = CHARL129; twoInt129[0] = DELTA129;
         oneUint129[0] = ECHO129;
         oneByte129[0] = GOLF129; twoByte129[0] = HOTEL129;
         oneUbyte129[0] = INDIA129;
         oneShort129[0] = KILO129;
         oneLong129[0] = MIKE129;
         oneBit129[0] = OSCAR129;
         oneLogic129[0] = QUEBE129;
         oneInteg129[0] = SIERR129; twoInteg129[0] = TANGO129; triInteg129[0] = SIERR129;
      endtask
   endclass
endpackage

module top129d;
   import pk129d::*;
   Tally129 deskJob129;
   initial begin
      deskJob129 = new();
      deskJob129.run129();
   end
endmodule
