// VERIFIER arm v1 — the POSITION axis, which a1/a2 never vary: every call in
// both shipped arms sits inside an `if (...)` CONDITION.  Defect B is exactly
// a position-dependence bug, so the OTHER positions must be pinned too.
package q1;

  function int fe(int v);            // package free function
    return v + 100;
  endfunction

  class base;
    function int fe(int v);          // shadows q1::fe
      return v + 1;
    endfunction
  endclass

  class derived extends base;
    int r;
    // POSITION 1: plain assignment RHS (classMethodNoBind was TRUE here)
    function void p_assign();
      r = fe(1);
    endfunction
    // POSITION 2: inside an if CONDITION (the only one a1/a2 test)
    function void p_cond();
      if (fe(2)) r = 0;
    endfunction
    // POSITION 3: a case CONDITION
    function void p_case();
      case (fe(3))
        default: r = 0;
      endcase
    endfunction
    // POSITION 4: an argument to another call
    function void p_arg();
      $display("%0d", fe(4));
    endfunction
    // POSITION 5: a return expression
    function int p_ret();
      return fe(5);
    endfunction
    // POSITION 6: a loop condition
    function void p_loop();
      while (fe(6)) r = 0;
    endfunction
  endclass

endpackage

module top;
  import q1::*;
  q1::derived d;
  initial begin
    d = new();
    d.p_assign(); d.p_cond(); d.p_case();
    d.p_arg(); d.r = d.p_ret(); d.p_loop();
  end
endmodule
