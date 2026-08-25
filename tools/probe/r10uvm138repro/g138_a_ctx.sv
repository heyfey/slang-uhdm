// r10uvm138 arm A — CONTEXT grid: where a bare enumerator reference sits.
// One package, one enum typedef, one free function per context.
package p138a;

  typedef enum { A_ZERO, A_ONE, A_TWO } ea_t;

  parameter int PK = 3;

  // A1: return as a DIRECT statement of the body
  function ea_t f_ret();
    return A_ONE;
  endfunction

  // A2: return nested in an if
  function ea_t f_ifret(int q);
    if (q > 0)
      return A_TWO;
    return A_ZERO;
  endfunction

  // A3: return nested in an explicit begin/end
  function ea_t f_begret();
    begin
      return A_TWO;
    end
  endfunction

  // A4: return nested in a for loop
  function ea_t f_forret();
    for (int i = 0; i < 1; i++)
      return A_TWO;
    return A_ZERO;
  endfunction

  // A5: two direct statements (the synthetic begin is NOT a nesting)
  function ea_t f_two(int q);
    int t = q;
    return A_ONE;
  endfunction

  // A6: right-hand side of a blocking assignment
  function ea_t f_rhs();
    ea_t v;
    v = A_ONE;
    return v;
  endfunction

  // A7: a call argument
  function int f_help(ea_t e);
    return 0;
  endfunction
  function int f_callarg();
    return f_help(A_ONE);
  endfunction

  // A8: a comparison operand
  function bit f_cmp(ea_t e);
    return (e == A_ONE);
  endfunction

  // A9: a case item
  function int f_case(ea_t e);
    case (e)
      A_ONE: return 1;
      A_TWO: return 2;
      default: return 0;
    endcase
  endfunction

  // A10: a variable initializer
  function ea_t f_init();
    ea_t v = A_TWO;
    return v;
  endfunction

  // A11: a ternary arm
  function ea_t f_tern(int q);
    return (q > 0) ? A_ONE : A_TWO;
  endfunction

  // A12: returned inside an operation
  function int f_op();
    return A_ONE + 1;
  endfunction

  // A13: qualified spelling p138a::A_ONE returned directly
  function ea_t f_qual();
    return p138a::A_ONE;
  endfunction

endpackage
