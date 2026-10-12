// § rzMemberNoReparentDefView288v — (the refinement of § randWithCallParentByConsumer288) a with-form scope randomize as an assignment-pattern member, a streaming operand and a dist-free relational inside a concatenation
class pk;
  rand int x; int c; int a [2]; logic [31:0] z; logic [32:0] w;
  function void fa(); a = '{randomize(x) with { x > c; }, 0}; endfunction
  function void fb(); z = {<< {randomize(x) with { x > c; }}}; endfunction
  function void fc(); w = {(randomize(x) with { x > c; }) == 1, 32'h0}; endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
