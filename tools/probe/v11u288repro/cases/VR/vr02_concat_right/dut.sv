// § rzMemberNoReparentDefView288v — (the refinement of § randWithCallParentByConsumer288) a with-form scope randomize as the RIGHT member of a concatenation
class pk;
  rand int x; int c; logic [32:0] z;
  function void fb(); z = {1'b0, randomize(x) with { x > c; }}; endfunction
endclass
module top; pk p; initial begin p = new(); p.fb(); end endmodule
