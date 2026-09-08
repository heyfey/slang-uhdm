// v214 arm 9 — A `$unit` IMPORT OF AN UNRELATED PACKAGE.  `bind146` is
// non-empty (so § 146's re-point loop runs) but no name matches the clone
// listing's references, so the law's pool must be left alone.  The second half
// puts a package-parameter reference under a TYPESPEC RANGE inside the clone,
// whose parent chain passes a `ref_typespec` — § 146's own second gate.
import pv9o::*;
package pv9o;
  parameter int oa9 = 77;
endpackage
package pv9;
  parameter int na9 = 12;
  parameter nb9 = na9;
  function automatic int sink9(int a, int b); return a + b; endfunction
  class C9;
    extern function int rd9();
  endclass
  function int C9::rd9();
    logic [nb9-1:0] loc;
    loc = '0;
    return sink9(na9, nb9) + int'(loc);
  endfunction
endpackage
module topv9;
  pv9::C9 c = new();
  int x;
  initial x = c.rd9();
endmodule
