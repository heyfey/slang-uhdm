// § cloneOwnAggMemberChainName285
// a block-level struct local in a class method's importer copy
package a; typedef struct { int x; string y; } s_t;
  class C; extern function void w(); endclass
  function void C::w(); begin s_t v; v.x = 0; end endfunction endpackage
package b; import a::*; class F; function void r(); C k; k = null; endfunction endclass endpackage
module top; endmodule
