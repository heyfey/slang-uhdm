// v4 — EXPLICIT import (`import p::v`) instead of wildcard.  The site's `only23`
// filter runs on this path; the copy must still be made.
package p4;
  int v4 = 7;
  int w4 = 8;
endpackage
package q4;
  import p4::v4;
  class c4;
    int own4;
  endclass
endpackage
module m4;
  q4::c4 h4;
endmodule
