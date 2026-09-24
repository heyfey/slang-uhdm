// r10uvm116 arm B -- scope-form randomize WITHOUT a constraint block, and with
// TWO arguments; plus a zero-argument bare randomize() inside a class method.
class chooser_b;
  rand byte sel_one;
  rand byte sel_two;
  function int pick_pair();
    pick_pair = randomize(sel_one, sel_two);
  endfunction
  function int pick_none();
    pick_none = randomize();
  endfunction
  function int pick_solo();
    pick_solo = randomize(sel_two);
  endfunction
endclass
module top_b;
  chooser_b c_one;
  int r_b;
  initial begin
    c_one = new();
    r_b = c_one.pick_pair();
  end
endmodule
