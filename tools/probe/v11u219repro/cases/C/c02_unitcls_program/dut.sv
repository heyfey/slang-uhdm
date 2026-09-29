// § classTdAliasLastWriter214 — the aliased specialization typedef listed by a $unit class through a file-scope import and by a program
package p;
  class pool #(type T = int); T items[$]; endclass
  typedef pool #(string) spool_t;
  typedef pool #(string) epool_t;
endpackage
import p::*;
class user_c;
  epool_t ep;
endclass
program prg;
  import p::*;
  epool_t pp;
endprogram
module top;
  prg u();
  user_c c;
endmodule
