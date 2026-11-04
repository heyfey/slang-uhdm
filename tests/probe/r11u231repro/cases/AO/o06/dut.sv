// § tfArgImportCloneFollowsIn231 — two importer packages, CRLF-free control of o01 with a header-free task
package p;
  typedef enum {A0, A1, A2} e_t;
  class c1;
    extern task t(e_t x);
  endclass
  task c1::t(e_t x);
  endtask
endpackage
package q1;
  import p::*;
endpackage
package q2;
  import p::*;
endpackage
module top;
endmodule
