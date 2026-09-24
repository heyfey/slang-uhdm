// v131 arm C — nesting, disable fork, for loops, collisions.
module Cnest;
  int cnt, guard, spin;
  initial begin
    // nested fork inside a fork, both named
    fork : outerNest
      fork : innerNest cnt = 1; join_none : innerNest
      spin = 2;
    join : outerNest
    // nested EMPTY fork inside a NON-EMPTY fork
    fork : outerHasKid
      fork : innerEmpty join_any : innerEmpty
    join_none : outerHasKid
    // nested NON-EMPTY fork as the ONLY child
    fork : soleKid
      fork : kidBody cnt = 3; join : kidBody
    join_any : soleKid
    // unnamed outer with a named inner
    fork
      fork : deepOne spin = 4; join_none
    join
    // fork followed by disable fork
    fork : dfHost cnt = 5; join_none : dfHost
    disable fork;
    // fork with wait fork after
    fork spin = 6; join_none
    wait fork;
    // fork inside a for loop
    for (int ii = 0; ii < 3; ii++) begin
      fork : loopFork cnt = ii; join_none : loopFork
    end
    for (int jj = 0; jj < 2; jj++) fork spin = jj; join_any
    // a fork whose body disables its own label
    fork : selfKill
      begin cnt = 7; disable selfKill; end
    join : selfKill
  end
  // label that COLLIDES with a variable name declared in ANOTHER scope
  initial begin
    fork : guardName guard = 8; join_none : guardName
  end
  // fork in an always block
  always @(cnt) begin
    fork : alwFork spin = 9; join_any : alwFork
    fork spin = 10; join_none
  end
endmodule
// the colliding name lives here, in a different module
module Cother;
  int guardName;
  initial guardName = 99;
endmodule
