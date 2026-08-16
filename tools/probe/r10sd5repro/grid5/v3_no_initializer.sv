// v3 — NO INITIALIZER, so the declarator span already IS the name span.  The
// cell that proves the span rule is not "shrink the span" but "use the NAME
// node", by showing the copy does not move where there is nothing to trim.
package p3;
  int v3;
endpackage
package q3;
  import p3::*;
  class c3;
    int own3;
  endclass
endpackage
module m3;
  q3::c3 h3;
endmodule
