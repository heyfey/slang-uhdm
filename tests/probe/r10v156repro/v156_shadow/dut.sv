// r10v156 ADVERSARIAL ARM 4 — a USER class that SHADOWS a builtin name
// (`process` / `semaphore` / `mailbox`), returned across a package boundary.
// Surelog's `Design::addClassDefinition` registers the BUILTIN under the BARE
// name, so arm B's first form can hit from anywhere; our fence keys on the
// class's FILE, not on its NAME.  MEASUREMENT ONLY.  LHS IS ALWAYS GOLDEN.

package psh1v6;
  class process;                       // shadows the builtin name
  endclass
  class semaphore;
  endclass
  class plainv6;
  endclass
endpackage

package psh2v6;
  import psh1v6::*;
  class Uv6;
    function process   r_proc();  return null; endfunction  // FAR pkg, builtin NAME
    function semaphore r_sem();   return null; endfunction
    function plainv6   r_plain(); return null; endfunction  // control: ordinary name
  endclass
  function process pf_proc(); return null; endfunction
endpackage
