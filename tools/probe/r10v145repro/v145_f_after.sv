// r10v145 arm F -- a local declared AFTER a statement (quarantined: not legal
// SV inside a subroutine body; kept so the two binaries are measured to REJECT
// it IDENTICALLY rather than one of them accepting it).  MEASUREMENT ONLY.
package pf145v;
  function void after145v;
    int a = 1;
    $display(a);
    int b = 2;
    $display(b);
  endfunction
endpackage
