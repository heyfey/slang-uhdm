// § randWithCallParentByConsumer288 — immediate assert, assume, cover and a deferred assert over a with-form randomize
class pk;
  rand int x; int c, h;
  function void fa();
    assert (randomize(x) with { x > c; }) else h = 1;
    assume (randomize(x) with { x < c; }) h = 2;
    cover (randomize(x) with { x != c; }) h = 3;
    assert #0 (randomize(x) with { x == c; }) else $error("e");
  endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
