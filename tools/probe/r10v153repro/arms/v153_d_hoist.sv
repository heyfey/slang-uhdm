// r10v153 arm D — THE HOIST INTERACTION.  A module WILDCARD-IMPORTS the
// package, so § 75/§ 107 mint a module net per unbound class-property name.
// `y_hit` collides with the package listing (the binding replaces the mint);
// `y_miss` collides with nothing (the mint must SURVIVE).  LHS is golden.
package pvd153;
  int y_hit;
  class Cvd153;
    int y_hit;
    int y_miss;
    extern function void md153(int p);
    extern function void nd153(int p);
  endclass
  function void Cvd153::md153(int p);
    y_hit  = p;
    y_miss = p;
  endfunction
  function void Cvd153::nd153(int p);
    y_hit  = p + 1;
    y_miss = p + 1;
  endfunction
endpackage

module mvd153;
  import pvd153::*;
  Cvd153 cd = new();
  initial begin
    cd.md153(1);
    cd.nd153(2);
  end
endmodule
