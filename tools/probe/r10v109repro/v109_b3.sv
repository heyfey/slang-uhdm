// r10v109repro/v109_b3.sv - ADVERSARIAL: the MINT ORDER / SPAN.  The hoisted
// wire is minted at the FIRST recorded reference's span.  Removing the `= new`
// lvalue from the pool MOVES that span when the same property is also read
// plainly.  Also: a module that DECLARES a net of the property's name (the
// hoist BINDS instead of minting - does golden?).  MEASUREMENT ONLY.
package pkb3;

  class Cog3;
    int z;
    function new(int a = 0); z = a; endfunction
  endclass

  class Rig3;
    Cog3 firstNewAlpha;   // `= new` FIRST (line ~30), plain read LATER
    Cog3 firstReadBeta;   // plain read FIRST, `= new` LATER
    Cog3 shadowGamma;     // a net of THIS name is DECLARED in the module
    int  shadowDelta;     // ditto, plain LHS control
    extern function void b3a();
    extern function int  b3b();
  endclass

  function void Rig3::b3a();
    Cog3 loc3;
    firstNewAlpha  = new(1);      // E1  the `= new` comes FIRST
    loc3           = firstReadBeta;  // E2a a PLAIN read comes FIRST
    shadowGamma    = new(2);      // E3  `= new` on a name the module DECLARES
    shadowDelta    = 3;           // E4  plain LHS on a name the module DECLARES
  endfunction

  function int Rig3::b3b();
    Cog3 loc4;
    loc4          = firstNewAlpha;  // E1b a PLAIN read comes SECOND
    firstReadBeta = new(4);         // E2b the `= new` comes SECOND
    return loc4.z;
  endfunction

endpackage

import pkb3::*;

module topb3;
  wire shadowGamma;      // DECLARED, same name as the class property
  wire shadowDelta;      // DECLARED, same name as the class property
  Rig3 r3;
  int  o3;
  initial begin
    r3 = new();
    r3.b3a();
    o3 = r3.b3b();
  end
endmodule
