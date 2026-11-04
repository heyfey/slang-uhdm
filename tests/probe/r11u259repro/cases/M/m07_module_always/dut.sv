// § cloneMemberImporterListing259 (a module-level always block reading a member (no copy))
package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pr_t;
endpackage
package q;
  import p::*;
endpackage
module m;
  import p::*;
  pr_t v;
  logic [3:0] o;
  always_comb o = v.a;
endmodule
module top;
  m u();
endmodule
