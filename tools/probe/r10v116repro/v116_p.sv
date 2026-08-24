// v116 arm P -- this. / super. receivers, and the member form with null.
class base_p;
  rand int b_slot;
  int b_cap;
  function int roll_base();
    roll_base = randomize(b_slot);
  endfunction
endclass
class kid_p extends base_p;
  rand int k_slot;
  function int roll_this();
    roll_this = this.randomize();
  endfunction
  function int roll_this_arg();
    roll_this_arg = this.randomize(k_slot);
  endfunction
  function int roll_super();
    roll_super = super.randomize();
  endfunction
  function int roll_this_with();
    roll_this_with = this.randomize(k_slot) with { k_slot > b_cap; };
  endfunction
  function int roll_bare();
    roll_bare = randomize();
  endfunction
endclass
module top_p;
  kid_p k_one;
  int r_p;
  initial begin
    k_one = new();
    r_p = k_one.roll_this();
  end
endmodule
