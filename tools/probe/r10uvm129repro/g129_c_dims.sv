// r10uvm129 grid C — the SAME two element types across every DIMENSION KIND a
// declarator array can carry.  MEASUREMENT ONLY.
package pk129c;
   typedef enum { WANE129, WAX129 } phase129_e;          // int base -> signed
   class Barrel129;
      int stave129;
   endclass

   class Cooper129;
      task fit129();
         int         fixCount129 [2];
         phase129_e  fixMood129  [3];
         int         twoCount129 [4][5];
         phase129_e  twoMood129  [6][7];
         int         dynCount129 [];
         phase129_e  dynMood129  [];
         int         queCount129 [$];
         phase129_e  queMood129  [$];
         int         strCount129 [string];
         phase129_e  strMood129  [string];
         int         intCount129 [int];
         phase129_e  intMood129  [int];
         int         clsCount129 [Barrel129];
         phase129_e  clsMood129  [Barrel129];
         int         mixCount129 [8][];
         phase129_e  mixMood129  [9][];
         fixCount129[0] = 1; fixMood129[0] = WANE129;
         twoCount129[0][0] = 1; twoMood129[0][0] = WAX129;
         dynCount129 = new[2]; dynMood129 = new[2];
         queCount129.push_back(1); queMood129.push_back(WANE129);
         strCount129["k"] = 1; strMood129["k"] = WAX129;
         intCount129[0] = 1; intMood129[0] = WANE129;
         mixCount129[0] = new[2]; mixMood129[0] = new[2];
      endtask
   endclass
endpackage

module top129c;
   import pk129c::*;
   Cooper129 shop129;
   initial begin
      shop129 = new();
      shop129.fit129();
   end
endmodule
