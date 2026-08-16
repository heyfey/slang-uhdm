// VERIFIER arm — OUT-OF-BODY TASK (not function) + an enum const read inside a
// default ARGUMENT and inside a fork.  Same law, different subroutine kinds.
package p76t;
  class c76;
    typedef enum {T_A, T_B} t76_t;
    t76_t m;
    extern task oobt(int k);
  endclass
  task c76::oobt(int k);
    if (m == T_A) k = k + 1;
    fork
      if (m == T_B) k = k + 2;
    join_none
  endtask
endpackage
import p76t::*;
module top76t;
  c76 c;
  initial begin
    c = new();
    c.oobt(1);
  end
endmodule
