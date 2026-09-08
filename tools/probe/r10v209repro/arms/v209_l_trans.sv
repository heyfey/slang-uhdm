// v209 verifier arm L — THE TRANSITIVE CLONE.  p1 has out-of-body constructor
// locals; p2 wildcard-imports p1 and so clones them; a module wildcard-imports
// p2.  Three listings carry the same faces (the package's own, p2's clone,
// the module's DEF and ELAB copies) and the law must give one value to all.
package pl209a;
  class cl209a;
    int n;
  endclass
  cl209a pla_own;
  class cl209b;
    int q;
    extern function new();
  endclass
  function cl209b::new();
    cl209a        lla_plain;
    static cl209a lla_static;
    int           lla_int;
    lla_plain = null;
    lla_static = null;
    q = 7;
  endfunction
endpackage

package pl209b;
  import pl209a::*;
  int plb_own;
endpackage

module gl209;
  import pl209b::*;
  initial $display("l");
endmodule
