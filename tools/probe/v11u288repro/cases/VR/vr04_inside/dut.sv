// § rzMemberNoReparentDefView288v — (the refinement of § randWithCallParentByConsumer288) a with-form scope randomize as an inside left side and as an inside set member
class pk;
  rand int x; int c, y;
  function void fa(); y = (randomize(x) with { x > c; }) inside {0, 1}; endfunction
  function void fb(); y = c inside {randomize(x) with { x > c; }, 2}; endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
