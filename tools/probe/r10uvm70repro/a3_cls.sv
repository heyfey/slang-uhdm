// r10uvm70 arm a3 — the UVM head's OWN shape: a CLASS method inside a PACKAGE,
// with a queue `ref` formal, exactly like
//   uvm_tr_stream.svh:371  function unsigned get_recorders(ref uvm_recorder q[$]);
// plus the class-PROPERTY site and an EXTERN out-of-body method, so the pass
// can tell "return var" from "any variable" and "in-class" from "out-of-body".
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package p3;
  class rec3;
    int id;
  endclass

  class holder3;
    rec3 m_records[int];

    // THE HEAD'S SHAPE, verbatim in form
    function unsigned get_recorders(ref rec3 q[$]);   // line 15
      q.delete();
      foreach (m_records[idx])
        q.push_back(m_records[idx]);
      return q.size();
    endfunction : get_recorders

    // direction sibling
    function signed get_signed(ref rec3 q[$]);        // line 22
      return q.size();
    endfunction

    // with a range
    function unsigned [7:0] get_ranged();             // line 27
      return 8'd0;
    endfunction

    // fully implicit (control)
    function get_implicit();                          // line 32
      return 1'b0;
    endfunction

    // explicit-base control
    function logic unsigned get_lg_u();               // line 37
      return 1'b0;
    endfunction

    // CLASS PROPERTIES with the same spelling
    var unsigned prop_u;                              // line 42
    var signed   prop_s;                              // line 43
    logic unsigned prop_lg_u;                         // line 44

    // an EXTERN method whose body is out of the class body
    extern function unsigned ex_u();                  // line 47
  endclass

  function unsigned holder3::ex_u();                  // line 50
    var unsigned exl_u;                               // line 51
    exl_u = 1'b0;
    return exl_u;
  endfunction

  // a PACKAGE-homed free function with the same return spelling
  function unsigned pk_u();                           // line 57
    return 1'b0;
  endfunction
endpackage

module a3;
  import p3::*;
  holder3 h;
  initial h = new();
endmodule
