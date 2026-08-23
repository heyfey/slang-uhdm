// r10v113 / v113_enc.sv — non-package enclosures: module, program, interface,
// $unit, and a class nested in each.  The free subroutine lives in the
// ENCLOSING construct, not in a package.
function automatic int unitFree(int z); return z + 1; endfunction   // $unit

class UnitCls;                       // a $unit class
  function int callsUnit(); return unitFree(81); endfunction
  function int unitFree(int z); return z + 900; endfunction
endclass

module tb_enc;
  function automatic int modFree(int z); return z + 2; endfunction
  class ModCls;
    function int callsMod(); return modFree(82); endfunction
    function int modFree(int z); return z + 910; endfunction
  endclass
  ModCls mc; UnitCls uc;
  initial begin mc = new(); uc = new(); end
endmodule

interface if_enc;
  function automatic int ifFree(int z); return z + 3; endfunction
  class IfCls;
    function int callsIf(); return ifFree(83); endfunction
    function int ifFree(int z); return z + 920; endfunction
  endclass
endinterface

program prog_enc;
  function automatic int prFree(int z); return z + 4; endfunction
  class PrCls;
    function int callsPr(); return prFree(84); endfunction
    function int prFree(int z); return z + 930; endfunction
  endclass
  PrCls pc;
  initial begin pc = new(); end
endprogram
