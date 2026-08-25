// r10uvm129 grid B — the SAME two element types (a signed-base enum typedef
// and a bare `int`) declared as a declarator array in ELEVEN different homes.
// The `int` cells are the POSITIVE CONTROL that must keep vpiSigned; the enum
// cells are the law's population.  MEASUREMENT ONLY.
package pk129b;
   typedef enum { SLACK129, TAUT129 } tension129_e;      // int base -> signed
   int packLevel129 [3];                                 // package variable
   tension129_e packMood129 [4];

   function automatic int packTally129();
      int  fnCount129 [5];
      tension129_e fnMood129 [6];
      fnCount129[0] = 1; fnMood129[0] = SLACK129;
      return fnCount129[0];
   endfunction

   function int packBare129;                             // paren-less: TF-ITEM
      int  bareCount129 [7];
      tension129_e bareMood129 [8];
      bareCount129[0] = 1; bareMood129[0] = TAUT129;
      packBare129 = bareCount129[0];
   endfunction

   class Loom129;
      int  propCount129 [9];                             // class property
      tension129_e propMood129 [10];
      extern task weave129();
      task spin129();                                    // in-body class task
         int  spinCount129 [11];
         tension129_e spinMood129 [12];
         spinCount129[0] = 1; spinMood129[0] = SLACK129;
      endtask
      function int count129();                           // in-body class fn
         int  fnLocal129 [13];
         tension129_e fnLocalMood129 [14];
         fnLocal129[0] = 1; fnLocalMood129[0] = TAUT129;
         return fnLocal129[0];
      endfunction
   endclass

   task Loom129::weave129();                             // OUT-OF-BODY method
      int  oobCount129 [15];
      tension129_e oobMood129 [16];
      oobCount129[0] = 1; oobMood129[0] = SLACK129;
   endtask
endpackage

module top129b;
   import pk129b::*;
   int  modCount129 [17];                                // module variable
   tension129_e modMood129 [18];

   task modTask129();                                    // module task
      int  mtCount129 [19];
      tension129_e mtMood129 [20];
      mtCount129[0] = 1; mtMood129[0] = TAUT129;
   endtask

   function automatic int argTake129(input int argCount129 [21],
                                     input tension129_e argMood129 [22]);
      return argCount129[0];
   endfunction

   initial begin : blk129b                               // begin-block local
      int  blkCount129 [23];
      tension129_e blkMood129 [24];
      blkCount129[0] = 1; blkMood129[0] = SLACK129;
      modTask129();
   end
endmodule
