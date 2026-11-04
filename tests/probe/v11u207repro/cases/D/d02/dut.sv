// § bitSelMethodCallIdxSpan207: static class methods, package functions and plain calls as indices (controls: their bound range is already the invocation)
package p;
  function automatic int pf(int a); return a; endfunction
class C;
  static function int sg(int a = 1); return a; endfunction
  int m[int];
  function int f(); return m[C::sg(2)] + m[p::pf(1)] + m[sg()] + m[pf(3)]; endfunction
endclass
endpackage
module top(output int o);
  int tbl[8];
  initial o = tbl[p::C::sg(1)] + tbl[p::pf(2)];
endmodule
