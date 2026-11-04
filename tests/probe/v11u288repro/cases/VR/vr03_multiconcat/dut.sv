// § randWithCallParentByConsumer288 — a with-form scope randomize inside a replication
class pk;
  rand int x; int c; logic [63:0] z;
  function void fa(); z = {2{randomize(x) with { x > c; }}}; endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
