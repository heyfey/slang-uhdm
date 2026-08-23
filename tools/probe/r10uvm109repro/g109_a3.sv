// r10uvm109repro/g109_a3.sv - THE OWNER GRID.  Two TOPS, one child instance and
// one module that imports the package but calls nothing, so the "which module
// mints the wire" behaviour (uvm107 R-MULTI) is measured on BOTH sides of this
// pass's fence.  MEASUREMENT ONLY.
package zoo3;
  class Cell3;
    int v;
    function new(int a = 0); v = a; endfunction
  endclass
  class Rack3;
    Cell3 slotNew1;             // `= new` LHS  -> golden mints NOTHING
    int   plainSet2;            // plain LHS    -> golden MINTS
    extern function void arrange();
  endclass
  function void Rack3::arrange();
    slotNew1  = new(3);
    plainSet2 = 4;
  endfunction
endpackage

module kid3;
  import zoo3::*;
  Rack3 r3;
  initial begin r3 = new(); r3.arrange(); end
endmodule

module topA3;
  import zoo3::*;
  Rack3 ra3;
  kid3 k3();
  initial begin ra3 = new(); ra3.arrange(); end
endmodule

module topB3;
  import zoo3::*;             // imports, never calls
  int idle3;
  initial idle3 = 1;
endmodule

module topC3;                 // imports NOTHING
  int lone3;
  initial lone3 = 2;
endmodule
