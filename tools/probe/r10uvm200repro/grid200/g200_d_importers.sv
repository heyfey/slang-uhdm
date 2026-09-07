// r10uvm200 grid arm D — WHICH IMPORTER materializes a clone: a package
// (clone), a module / interface / program (NO clone: importPackage shares the
// task_func), an EXPLICIT item import, and a re-export chain.
package pa200d;
  parameter WE = 11;
  function logic [WE:0] fd(input logic [WE:0] a);
    fd = a;
  endfunction
endpackage

package pmid200d;
  import pa200d::*;
endpackage

package pouter200d;
  import pmid200d::*;
endpackage

package pexp200d;
  import pa200d::fd;
endpackage

interface if200d;
  import pa200d::*;
endinterface

program pg200d;
  import pa200d::*;
  initial $display(WE);
endprogram

module top200d;
  import pa200d::*;
  if200d i0();
  initial $display(WE);
endmodule
