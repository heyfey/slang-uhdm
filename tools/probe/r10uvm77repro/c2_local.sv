// r10uvm77 arm c2 — THE BINDING HALF.  Does golden's scoped `ref_obj` require a
// SAME-NAMED LOCAL in scope?  The brief asserts it does ("golden's ref_obj
// fullname scopes to the FUNCTION-LOCAL status @grant_queued_locks").
//
// Four cells, the 2x2 of {same-named local present, absent} x {parens-less,
// parens-ful}, all four reading the SAME built-in on the SAME handle.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

module top77c2;
  process p;
  int     r;

  // L: a function that DOES declare a local named `status`.
  function int withloc;
    int status;
    status = 7;
    if (p.status == process::KILLED)     // L1 parens-less, local in scope
      r = status;
    if (p.status() == process::KILLED)   // L2 parens-ful, local in scope
      r = 2;
    return r;
  endfunction

  // N: a function that does NOT.  Nothing named `status` is visible.
  function int noloc;
    int other;
    other = 7;
    if (p.status == process::KILLED)     // N1 parens-less, NO local
      r = other;
    if (p.status() == process::KILLED)   // N2 parens-ful, NO local
      r = 2;
    return r;
  endfunction

  // M: MODULE scope, outside any subroutine, and no local anywhere.
  initial begin
    if (p.status == process::FINISHED)   // M1 parens-less, module scope
      r = 5;
  end
endmodule
