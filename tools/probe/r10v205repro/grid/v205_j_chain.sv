// r10v205 arm J — THE IMPORT CHAIN.  Three packages: `a` declares the typedef
// and the subroutine, `b` wildcard-imports `a`, `c` wildcard-imports `b`.  The
// clone in `c` carries a typedef whose HOME is two packages away, and `b`'s own
// subroutine (whose clone lands in `c`) mixes an `a` typedef with a `b` typedef.
// Golden's `writeDataTypes` qualifies with the package it is WALKING, so the
// question is which prefix a two-hop clone's alias target would carry if it
// carried one at all.
package p205a_j;
  typedef bit [7:0] at205;
  function automatic int fa_j205(input at205 aio205[]);
    at205 aloc205[];
    return aio205.size() + aloc205.size();
  endfunction
endpackage

package p205b_j;
  import p205a_j::*;
  typedef bit [15:0] bt205;
  function automatic int fb_j205(input at205 bio205[]);
    at205 bloc_a205[];        // typedef from package A, body in package B
    bt205 bloc_b205[];        // typedef from package B, body in package B
    return bio205.size() + bloc_a205.size() + bloc_b205.size()
         + fa_j205(bio205);
  endfunction
endpackage

package p205c_j;
  import p205b_j::*;
  import p205a_j::*;
  function automatic int fc_j205();
    at205 cloc_a205[];
    bt205 cloc_b205[];
    return fb_j205(cloc_a205) + cloc_b205.size();
  endfunction
endpackage

module v205_j_chain;
  import p205c_j::*;
  int r205;
  initial r205 = fc_j205();
endmodule
