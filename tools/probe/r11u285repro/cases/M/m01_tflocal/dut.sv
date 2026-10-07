// § cloneOwnAggMemberChainName285
// an importer copy of a package function with a struct local
package a; typedef struct { int x; int y; } s_t;
  function automatic int f(); s_t v; v.x = 1; return v.x; endfunction endpackage
package b; import a::*; function automatic int g(); return f(); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule
