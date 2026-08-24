// v119 arm I — COMPOSITION: two randomize-with calls in one expression, a
// randomize-with as another call's argument, a multi-LINE with block, a
// function call inside the block, and a case-expression position.
class it_i;
  rand int unsigned i_a;
  rand int unsigned i_b;
  function int unsigned cap_i();
    return 30;
  endfunction
endclass

class drv_i;
  it_i p_i;
  it_i q_i;
  int unsigned out_i;
  function bit take_i(bit v_i);
    return v_i;
  endfunction
  task run_i();
    // TWO randomize-with calls in ONE expression
    if (!p_i.randomize() with { i_a > 1; } && !q_i.randomize() with { i_b > 2; })
      out_i = 1;
    // a randomize-with as an ARGUMENT of another call
    if (take_i(p_i.randomize() with { i_a > 3; })) out_i = 2;
    // a MULTI-LINE with block: the span end is on a different line
    if (!p_i.randomize() with {
          i_a > 4;
          i_b < 20;
        }) out_i = 3;
    // a FUNCTION CALL inside the block
    if (!p_i.randomize() with { i_a < cap_i(); }) out_i = 4;
    // a case expression
    case (p_i.randomize() with { i_a > 5; })
      1'b1: out_i = 5;
      default: out_i = 6;
    endcase
    // inside fork/join_none
    fork
      if (!q_i.randomize() with { i_b > 6; }) out_i = 7;
    join_none
  endtask
endclass

module top_i;
  drv_i d_i;
  initial begin
    d_i = new();
    d_i.run_i();
  end
endmodule
