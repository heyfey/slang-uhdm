// ARM I — THE OTHER PLACEHOLDER KINDS IN THE SAME LISTING.  A class-scoped
// typedef spelling (`Owner::td`) and a statement-scope typedef, both of which
// degrade to their own `unsupported_typespec` through a DIFFERENT site
// (`tsInst` / `pkgScopeInst`, not the type-parameter pointer).  They share the
// def-view clone listing with the law's objects, so this arm is where a fix
// that over-fires would show.
package p213i;
  class own213;
    typedef bit [5:0] td213_t;
  endclass
  class c213i;
    extern function void fi213(own213::td213_t x213);
    extern function void gi213();
  endclass
  function void c213i::fi213(own213::td213_t x213);
    own213::td213_t loci213;
    loci213 = x213;
  endfunction
  function void c213i::gi213();
    typedef bit [2:0] stmt213_t;
    stmt213_t locsi213;
    locsi213 = 3'b0;
  endfunction
endpackage
module top213i;
  initial begin end
endmodule
