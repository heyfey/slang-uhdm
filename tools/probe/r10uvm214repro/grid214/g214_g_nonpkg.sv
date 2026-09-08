// r10uvm214 grid arm G — THE NON-PACKAGE HOMES.  A MODULE-homed class and a
// `$unit`-scope class with out-of-body methods that read a package parameter.
// Neither home produces a package Task_funcs clone listing, so the law's window
// (`pkgClassTfClone && !pkgImportCloneEmit`) is never open here and no cell may
// move.
package pm214;
  parameter int ma214 = 13;
  parameter mb214 = ma214;
endpackage

class U214;
  extern function int u_rd214();
endclass

function int U214::u_rd214();
  return pm214::mb214 + 1;
endfunction

module topg214;
  import pm214::*;

  class M214;
    extern function int m_rd214();
  endclass

  function int M214::m_rd214();
    return mb214 + ma214;
  endfunction

  M214 m = new();
  U214 u = new();
  int x, y;
  initial begin
    x = m.m_rd214();
    y = u.u_rd214();
  end
endmodule
