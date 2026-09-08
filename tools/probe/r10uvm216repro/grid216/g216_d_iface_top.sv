// r10uvm216 ARM D — THE CORPUS TOPOLOGY.  The interface is a TOP-LEVEL
// instance with NO module instantiating it — exactly MiniAmiq, where
// `svaunit_vpi_interface` is compiled from the command line and no design
// instantiates it.  Arm A puts the interface under a module; this arm asks
// whether being a TOP instance (vs. an instance under a module) changes the
// answer, in either view.
interface d216_if();
   import "DPI-C" context function void d216_imp(input int x);

   export "DPI-C" function d216_second;
   export "DPI-C" function d216_first;

   int d216_state;

   function void d216_plain1(int p);
      d216_state = p;
   endfunction

   function int d216_plain2(int p);
      return p + 1;
   endfunction

   function void d216_first(input int a, input string b);
      d216_state = a;
      d216_imp(a);
   endfunction

   function int d216_second(input int a);
      return a + d216_state;
   endfunction

   function void d216_plain4();
      d216_state = 0;
   endfunction
endinterface
