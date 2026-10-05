// § cloneTfItemLocalOwnVar253 (a local used as a for bound and a loop variable declared in the for)
package p;
  function automatic int f;
    int n;
    int acc;
    n = 4;
    acc = 0;
    for (int i = 0; i < n; i++) acc += i;
    return acc;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
