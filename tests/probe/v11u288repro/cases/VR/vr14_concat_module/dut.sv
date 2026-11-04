// § rzMemberNoReparentDefView288v — (the refinement of § randWithCallParentByConsumer288) two with-form scope randomize calls as concatenation members in a package class and a module task
package rq;
  class pk;
    rand int x; int c; logic [63:0] z;
    task ta(); z = {randomize(x) with { x > c; }, randomize(x) with { x < c; }}; endtask
  endclass
endpackage
module top; import rq::*; pk p; initial begin p = new(); p.ta(); end endmodule
