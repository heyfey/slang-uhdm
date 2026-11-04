// (r11u191 N0224) a method call in a range select's bound (uvm_sequencer_base.svh 694) and in an indexed range's width
class F;
  int q[$];
  int r[$];
  function void f(int b);
    r = {r, q[b:q.size()-1]};
    r = {r, q[b+:q.size()]};
  endfunction
endclass
module top; endmodule
