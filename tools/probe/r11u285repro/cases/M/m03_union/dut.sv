// § cloneOwnAggMemberChainName285
// a union local
package a; typedef union { int x; shortint y; } u_t;
  function automatic int f(); u_t v; v.x = 1; return v.x; endfunction endpackage
package b; import a::*; function automatic int g(); return f(); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule
