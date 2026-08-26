// r10uvm156 — the 1-3 INSTANCE axis and the DEF/ELAB axis.  The same module
// body is instantiated once, twice and three times; a module-scope class and a
// package class are returned from every copy.  MEASUREMENT ONLY.

package pc156;
  class cfar156;
  endclass
endpackage

module leaf156;
  import pc156::*;
  class lcls156;
  endclass
  class lhome156;
    function lcls156 r_same(); return null; endfunction   // same MODULE -> anonymous
    function cfar156 r_far();  return null; endfunction   // far package  -> NAMED
  endclass
  function lcls156 lf_same(); return null; endfunction
  function cfar156 lf_far();  return null; endfunction
  lhome156 h156;
  initial h156 = new();
endmodule

module mid156;
  leaf156 u1();
  leaf156 u2();
endmodule

module topc156;
  leaf156 u0();
  mid156  um();
endmodule
