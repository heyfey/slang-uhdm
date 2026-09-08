// r10uvm218 arm a3 — THE MUST-STAY CONTROL.  Every OTHER home for a subroutine
// body, each carrying the same three cells (a condition, a call-statement
// argument and a plain assignment).  Not one of them is an uninstantiated
// interface, so not one cell may move: the law's flag is raised at exactly one
// call site and is false in all of these.
package p318;
   function void pcallee318(int z); endfunction
   function void pf318(int a_x);
      int loc318;
      if (a_x == 1) loc318 = 1;            // p01 package fn, cond
      pcallee318(a_x);                     // p02 package fn, call-stmt arg
      loc318 = a_x;                        // p03 package fn, assign RHS
   endfunction
endpackage

class c318;
   int prop318;
   function void ccallee318(int z); endfunction
   function void cf318(int a_x);           // IN-BODY method
      int loc318;
      if (a_x == 1) loc318 = 1;            // c01
      ccallee318(a_x);                     // c02
      loc318 = a_x;                        // c03
   endfunction
   extern function void cx318(int a_x);
endclass

function void c318::cx318(int a_x);        // OUT-OF-BODY definition
   int loc318;
   if (a_x == 1) loc318 = 1;               // x01
   ccallee318(a_x);                        // x02
   loc318 = a_x;                           // x03
endfunction

interface if318_in;                        // INSTANTIATED
   bit gv318i;
   function void icallee318(int z); endfunction
   function void if318(int a_x);
      int loc318;
      if (a_x == 1) loc318 = 1;            // i01
      icallee318(a_x);                     // i02
      loc318 = a_x;                        // i03
   endfunction
endinterface

module m318_ports(input logic clk318);     // NEVER instantiated, HAS PORTS
   function void mcallee318(int z); endfunction
   function void mf318(int a_x);
      int loc318;
      if (a_x == 1) loc318 = 1;            // u01 (buvm13 m13_unused2: golden BINDS)
      mcallee318(a_x);                     // u02
      loc318 = a_x;                        // u03
   endfunction
endmodule

program pr318_un;                          // NEVER instantiated PROGRAM
   function void rcallee318(int z); endfunction
   function void rf318(int a_x);
      int loc318;
      if (a_x == 1) loc318 = 1;            // r01
      rcallee318(a_x);                     // r02
      loc318 = a_x;                        // r03
   endfunction
endprogram

module top318;
   if318_in the_if318();
   function void tcallee318(int z); endfunction
   function void tf318(int a_x);
      int loc318;
      if (a_x == 1) loc318 = 1;            // t01
      tcallee318(a_x);                     // t02
      loc318 = a_x;                        // t03
   endfunction
endmodule
