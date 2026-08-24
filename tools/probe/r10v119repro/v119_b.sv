// v119 arm B — a FUNCTION-RETURN receiver, ISOLATED
class item_b;
  rand int unsigned b_v;
endclass

class fact_b;
  item_b keep_b;
  int unsigned out_b;
  function item_b get_b();
    return keep_b;
  endfunction
  task run_b();
    // a call whose receiver is itself a call
    if (!get_b().randomize() with { b_v > 1; }) out_b = 1;
    // and the plain member form beside it, same scope
    if (!keep_b.randomize() with { b_v > 2; }) out_b = 2;
  endtask
endclass

module top_b;
  fact_b f_b;
  initial begin
    f_b = new();
    f_b.keep_b = new();
    f_b.run_b();
  end
endmodule
