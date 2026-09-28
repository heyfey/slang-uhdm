// § namedSlotFillerRootFile207 (two root files: the callee's package in a.sv, the callers in b.sv)
package pa;
  function automatic int f(int a, int b = 1, int c = 2);
    return a + b + c;
  endfunction
endpackage
