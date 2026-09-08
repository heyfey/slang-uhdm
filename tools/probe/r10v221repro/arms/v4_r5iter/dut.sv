// v4_r5iter — § 218's R5 COLLISION FACE, rebuilt independently.  The declined
// mint sits in the same `else if (suppressRefActual)` branch as the for-loop
// ITERATOR bind two blocks below it (ExprEmit.cpp ~17930, keyed on
// `activeForVars` and reached only when `!ref->Actual_group()`).  Declining an
// ENUM actual leaves that ref bare — so if the iterator arm were keyed on
// "bare" alone rather than on the symbol being an iterator, an enum reference
// would fall through into it and bind an int_var.  Iterators and enum
// constants are interleaved here in the SAME expressions so a fallthrough
// cannot hide.
package v4pkg;
  typedef enum logic [2:0] { R_A = 3'd0, R_B = 3'd1, R_C = 3'd2 } r_e;
endpackage

interface v4_if (input logic clk);
  import v4pkg::*;
  typedef enum logic [2:0] { S_X = 3'd0, S_Y = 3'd1 } s_e;

  function automatic int f_mix(input int n);
    int acc = 0;
    for (int i = 0; i < n; i++) begin        // iterator i
      acc += i + int'(R_A);                  // iterator BESIDE an enum const
      if (i == int'(S_X)) acc += int'(R_B);  // iterator IN a comparison w/ enum
    end
    for (int j = 0; j < n; j++)
      acc += (j < int'(R_C)) ? int'(S_Y) : j;
    return acc;
  endfunction

  function automatic int f_foreach(input int arr[4]);
    int acc = 0;
    foreach (arr[k]) acc += arr[k] + int'(R_C);  // foreach iterator + enum
    return acc;
  endfunction
endinterface

// A top module so the design HAS a top — an interface with a PORT LIST in a
// design with no top-level module segfaults BOTH binaries (pre-existing; see
// the verifier README residue V-R1).  It instantiates NOTHING, so every
// interface above stays UNINSTANTIATED.
module v4_r5iter_top (input logic clk);
endmodule
