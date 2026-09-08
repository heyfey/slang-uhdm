// r10uvm216 ARM A — THE LAW.  An INTERFACE whose `export "DPI-C"` declarations
// sit FAR AHEAD of the exported functions' definitions, with plain functions
// and a DPI IMPORT in between, and with the two exports in the OPPOSITE order
// to the two definitions.  This is the MiniAmiq
// (`svaunit/sv/svaunit_vpi_interface.sv`) shape, reduced.
//
// The three questions this arm asks at once:
//   (1) WHERE in the interface's `Task_funcs` does the exported function sit --
//       at the `export` item, or at the definition item?
//   (2) WHAT does it carry -- vpiAccessType (3 = vpiDPIExportAcc) and
//       vpiDPICStr (2 = vpiDPIC)?
//   (3) WHOSE SPAN does it carry -- the export declaration's, or the
//       definition's?
interface a216_if();
   // a DPI IMPORT first, so the import path is exercised in the same listing
   import "DPI-C" context function void a216_imp(input int x);

   // the two EXPORTS, in the opposite order to the definitions below
   export "DPI-C" function a216_second;
   export "DPI-C" function a216_first;

   int a216_state;

   // three PLAIN functions between the exports and the definitions
   function void a216_plain1(int p);
      a216_state = p;
   endfunction

   function int a216_plain2(int p);
      return p + 1;
   endfunction

   task a216_plain3(int p);
      a216_state = p;
   endtask

   // the DEFINITIONS, in the opposite order to the exports above
   function void a216_first(input int a, input string b);
      a216_state = a;
      a216_imp(a);
   endfunction

   function int a216_second(input int a);
      return a + a216_state;
   endfunction

   function void a216_plain4();
      a216_state = 0;
   endfunction
endinterface

module a216_top();
   a216_if u_if();
endmodule
