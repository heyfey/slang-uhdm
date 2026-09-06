// r10v175 verifier arm H — the HOME the with-form call is written in.
package burrow_mill;
  class shim;
    string words[$];
    int heft[$];
    function new(); endfunction
  endclass
  class rack;
    shim trays[$];
    int found[$];
    int amount;
    string target;
    function new(); endfunction
    extern function void outofbody(int lane);
    function void inbody(int lane);
      found = trays[lane].words.find_index() with (item == target);
    endfunction
    virtual function void virt(int lane);
      amount = trays[lane].heft.sum() with (item);
    endfunction
    static function void stat(rack r, int lane);
      r.amount = r.trays[lane].heft.sum() with (item);
    endfunction
  endclass
  function void rack::outofbody(int lane);
    found = trays[lane].words.find_index() with (item == target);
  endfunction
  class holder;
    rack one;
    function new(); one = new(); endfunction
  endclass
  function automatic int freefn(rack r, int lane);
    return r.trays[lane].heft.sum() with (item);
  endfunction
endpackage

module burrow_top;
  import burrow_mill::*;
  rack shelf;
  int amount;
  int lane;
  initial begin
    shelf = new();
    // h_initial: module initial block
    amount = shelf.trays[lane].heft.sum() with (item);
  end
  always @(*) begin
    // h_always: module always block
    amount = shelf.trays[lane].heft.sum() with (item);
  end
  function automatic int modfn(int lane2);
    // h_modfn: module function
    return shelf.trays[lane2].heft.sum() with (item);
  endfunction
endmodule
