// r10uvm218 arm a4 — THE CORPUS SHAPE.  A DPI-EXPORTED function and task in an
// UNINSTANTIATED interface (svaunit_vpi_interface's own topology, reduced),
// plus a PORTED uninstantiated interface and a plain function beside them, so
// the law is measured on the exact object the MiniAmiq head names.
interface if418_un;                        // NEVER instantiated
   export "DPI-C" function pass418;        // the export ITEM, far above
   export "DPI-C" task     tsk418;
   import  "DPI-C" function int imp418();

   bit mv418;

   function void pass418(string a_ty, int a_rs);   // the DEFINITION, far below
      int loc418;
      if (a_ty == "vpiCover") begin        // d01 DPI-EXPORT fn, cond, formal
         mv418 = 1'b1;
      end
      helper418(a_rs);                     // d02 DPI-EXPORT fn, call-stmt arg
      loc418 = a_rs;                       // d03 DPI-EXPORT fn, assign RHS
      if (mv418) loc418 = 2;               // d04 iface MEMBER in a cond
   endfunction

   task tsk418(int a_q);
      int loc418;
      if (a_q == 1) mv418 = 1'b1;          // d05 DPI-EXPORT task, cond
      helper418(a_q);                      // d06 DPI-EXPORT task, call-stmt arg
      loc418 = a_q;                        // d07
   endtask

   function void plain418(int a_p);        // a PLAIN function, same interface
      int loc418;
      if (a_p == 1) mv418 = 1'b1;          // d08
      helper418(a_p);                      // d09
      loc418 = a_p;                        // d10
   endfunction

   function void helper418(int z); endfunction
endinterface

interface if418_p(input logic clk418);     // NEVER instantiated, HAS A PORT
   bit mv418p;
   function void pf418(int a_p);
      int loc418;
      if (a_p == 1) mv418p = 1'b1;         // e01
      helper418p(a_p);                     // e02
      loc418 = a_p;                        // e03
   endfunction
   function void helper418p(int z); endfunction
endinterface

module top418;
   initial begin end
endmodule
