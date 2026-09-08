// v2_uninst — THE LAW'S OWN FACE, written INDEPENDENTLY of the implementer's
// a1_ctx: the SAME body as v1_inst but with NO module instantiating it.
// writeInterface (UhdmWriter.cpp:1626-1794) calls neither late pass, so golden
// must leave EVERY enum-constant reference bare, in every context and in both
// views.  If golden binds even one, the law is false.
package v2pkg;
  typedef enum logic [1:0] { P_A = 2'd0, P_B = 2'd1, P_C = 2'd2 } p_e;
endpackage

interface v2_if (input logic clk);
  import v2pkg::*;
  typedef enum logic [2:0] { L_X = 3'd0, L_Y = 3'd1, L_Z = 3'd4 } l_e;
  logic [2:0] st;

  function automatic l_e f_cond(input int k);
    if (k == 0) return L_X;
    else if (k == 1) return L_Y;
    return L_Z;
  endfunction

  function automatic p_e f_case(input int k);
    case (k)
      0: return P_A;
      1: return P_B;
      default: return P_C;
    endcase
  endfunction

  task automatic t_assign(output logic [2:0] o);
    o = L_Y;
    if (o inside { L_X, L_Y, L_Z }) o = L_Z;
  endtask

  function automatic int f_arg();
    return $bits(L_Z) + int'(P_B);
  endfunction

  // extra contexts the corpus head exercises
  function automatic int f_more(input int k);
    int acc = 0;
    while (acc < int'(L_Z)) acc++;            // while condition
    for (int i = 0; i < 3; i++) acc += int'(P_C);  // for body
    begin : nb
      acc += int'(L_Y);                       // named block
    end
    return acc;
  endfunction
endinterface

// A top module so the design HAS a top — an interface with a PORT LIST in a
// design with no top-level module segfaults BOTH binaries (pre-existing; see
// the verifier README residue V-R1).  It instantiates NOTHING, so every
// interface above stays UNINSTANTIATED.
module v2_uninst_top (input logic clk);
endmodule
