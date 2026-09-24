// v1_inst — THE FIRST DECLINE FACE: an INSTANTIATED interface.
// Surelog's writeInstance (:4784 `if (mod && netlist)`) runs lateBinding over
// the elaborated scope, and the def-view listing shares those subroutine
// objects, so golden BINDS the enum-constant actuals here.  The patch must NOT
// touch a single cell of this arm.  TWO instances, to catch a law that keys on
// "the first instance" rather than the instance COUNT.
package v1pkg;
  typedef enum logic [1:0] { P_A = 2'd0, P_B = 2'd1, P_C = 2'd2 } p_e;
endpackage

interface v1_if (input logic clk);
  import v1pkg::*;
  typedef enum logic [2:0] { L_X = 3'd0, L_Y = 3'd1, L_Z = 3'd4 } l_e;
  logic [2:0] st;

  function automatic l_e f_cond(input int k);
    if (k == 0) return L_X;                 // condition + return
    else if (k == 1) return L_Y;
    return L_Z;
  endfunction

  function automatic p_e f_case(input int k);
    case (k)
      0: return P_A;                        // case item values
      1: return P_B;
      default: return P_C;
    endcase
  endfunction

  task automatic t_assign(output logic [2:0] o);
    o = L_Y;                                // assignment RHS
    if (o inside { L_X, L_Y, L_Z }) o = L_Z; // inside set
  endtask

  function automatic int f_arg();
    return $bits(L_Z) + int'(P_B);          // syscall arg + cast operand
  endfunction
endinterface

module v1_top (input logic clk);
  v1_if u0 (.clk(clk));                     // instance ONE
  v1_if u1 (.clk(clk));                     // instance TWO
endmodule
