// § rzMemberNoReparentDefView288v — (the refinement of § randWithCallParentByConsumer288) a with-form scope randomize as the LEFT member of a concatenation (Surelog's concatenation branch never re-parents its members)
class pk;
  rand int x; int c; logic [32:0] z;
  function void fa(); z = {randomize(x) with { x > c; }, 1'b0}; endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
