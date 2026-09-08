// r10uvm221 arm a3_muststay — THE MUST-STAY CONTROL.
//
// Every holder whose writer DOES call `UhdmWriter::lateBinding`
// (writePackage :1304, writeModule :1575/:1623, writeElabProgram :2072, the
// elaborated instance writer :4785) plus the two the campaign already knows
// behave otherwise (an out-of-body class method, an UNINSTANTIATED program).
// NOT ONE CELL HERE MAY MOVE.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package s221;
   typedef enum int {SE_A = 61, SE_B = 62} se221_t;

   function automatic int pkgf221(input int a_x);       // PACKAGE FUNCTION
      int loc;
      loc = SE_A;                                       // s01
      if (a_x == SE_B) loc = loc + 1;                   // s02
      return loc;
   endfunction

   class k221;
      typedef enum int {KE_A = 71, KE_B = 72} ke221_t;
      function int inb221(input int a_x);               // IN-BODY class method
         int loc;
         loc = KE_A;                                    // s03
         loc = SE_A;                                    // s04
         return loc;
      endfunction
      extern function int oob221(input int a_x);
   endclass

   function int k221::oob221(input int a_x);            // OUT-OF-BODY class method
      int loc;
      loc = KE_A;                                       // s05
      loc = SE_A;                                       // s06
      return loc;
   endfunction
endpackage

module m221un (input int p_i, output int p_o);           // UNINSTANTIATED MODULE
   import s221::*;                                       // (writeModule DOES late-bind)
   function int mf221(input int a_x);
      int loc;
      loc = SE_A;                                        // s07
      if (a_x == SE_B) loc = loc + 1;                    // s08
      return loc;
   endfunction
endmodule

program pr221un;                                         // UNINSTANTIATED PROGRAM
   import s221::*;
   function int pf221(input int a_x);
      int loc;
      loc = SE_A;                                        // s09
      if (a_x == SE_B) loc = loc + 1;                    // s10
      return loc;
   endfunction
endprogram

program pr221in;                                         // INSTANTIATED PROGRAM
   import s221::*;
   function int pf221(input int a_x);
      int loc;
      loc = SE_A;                                        // s11
      if (a_x == SE_B) loc = loc + 1;                    // s12
      return loc;
   endfunction
endprogram

module tops221;                                          // TOP MODULE
   import s221::*;
   pr221in u_pr ();
   function int tf221(input int a_x);
      int loc;
      loc = SE_A;                                        // s13
      if (a_x == SE_B) loc = loc + 1;                    // s14
      return loc;
   endfunction
endmodule
