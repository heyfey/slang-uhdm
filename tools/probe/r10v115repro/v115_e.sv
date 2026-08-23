// v115_e — CLASSES IN OTHER HOMES, and nested-generate subroutines.
module me_top;
  class mc_cls;                     // a class declared INSIDE a MODULE
    function void ib_fn();          // IN-BODY method of a module-nested class
      process ib_p;
    endfunction
    extern function void oob_fn();
  endclass
  function void mc_cls::oob_fn();   // OUT-OF-BODY, inside a module
    process ob_p;
  endfunction

  class outer_c;
    class inner_c;                  // a NESTED class
      function void in_fn();
        process in_p;
      endfunction
    endclass
    function void ot_fn();
      process ot_p;
      for (int i = 0; i < 2; i++) begin : loop_blk
        process lp_p;               // a FOR-LOOP body block item, in-body method
        lp_p = process::self();
      end
      case (1)
        1: begin : case_blk
             process cs_p;          // a CASE-ITEM block, in-body method
             cs_p = process::self();
           end
        default: ;
      endcase
      ib_dummy(ot_p, in_p_dummy());
    endfunction
    function void ib_dummy(process a, int b); endfunction
    function int in_p_dummy(); return 0; endfunction
  endclass

  initial begin
    for (int i = 0; i < 2; i++) begin : m_loop
      process ml_p;                 // FOR-LOOP body block item, module initial
      ml_p = process::self();
    end
    case (1)
      1: begin : m_case
           process mc_p;            // CASE-ITEM block, module initial
           mc_p = process::self();
         end
      default: ;
    endcase
    while (1) begin : m_while
      process mw_p;                 // WHILE body block, module initial
      mw_p = process::self();
      break;
    end
    fork
      begin : f1
        process fa_p;               // fork branch
        fa_p = process::self();
      end
      begin : f2
        process fb_p;
        fb_p = process::self();
      end
    join_none
  end
endmodule
