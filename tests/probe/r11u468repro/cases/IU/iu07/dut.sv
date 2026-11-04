// § unitInclClassImports468
// the import written inside the included file, the class in the main file
package p;
  parameter int P = 3;
  int v;
  function int f(); return 1; endfunction
endpackage
`include "i.sv"
class c;
  int x;
endclass
module top; c h; endmodule
