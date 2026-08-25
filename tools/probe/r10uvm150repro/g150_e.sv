// r10uvm150 arm E — the GRAMMAR FENCE.  Every cell here is REFUSED BY SURELOG'S
// PARSER (`[SNT:PA0207] Syntax error`), so no golden exists for it and the law
// says nothing about it.  Kept as a committed arm so the boundary gate still
// compiles the shapes and a later pass can see if Surelog ever learns them.
//   E1  `Cls::f().name[i]`      -> "no viable alternative at input 'tbl['"
//   E2  `Cls::f().a().b(...)`   -> "mismatched input '.' expecting ';'"
//   E3  `bare().a().b()`        -> same
//   E4  `Cls::f().arr.sum()`    -> same
// (Our binary parses all four; only the boundary gate scores them.)
package RR9;
  class N9;
    int V = 3;
    int tbl[3];
    function int GO(int a, int b); return a*b+V; endfunction
    function int NIL(); return V; endfunction
    function N9 nxt(); return this; endfunction
  endclass
  class B9;
    extern static function N9 OB();
  endclass
  function N9 B9::OB(); N9 n = new(); return n; endfunction
  function N9 freeN9(); N9 n = new(); return n; endfunction
endpackage
module TOPE;
  import RR9::*;
  function int e01(); return B9::OB().tbl[1]; endfunction        // E1
  function int e02(); return B9::OB().nxt().GO(1,2); endfunction // E2
  function int e03(); return freeN9().nxt().NIL(); endfunction   // E3
  function int e04(); return B9::OB().tbl.sum(); endfunction     // E4
endmodule
