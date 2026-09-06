// r10v169 arm G — CONTROL FLOW: recursion, two returns in one function, a
// void function's bare `return;`, a task's `return;`, and a return inside a
// fork/case — all inside a WILDCARD-IMPORTED package.  MEASUREMENT ONLY.
package p169hg;
  parameter int kg169 = 3;
  parameter int lg169 = 4;

  function automatic int f_rec169(input int n);
    if (n <= 0) return kg169;
    return f_rec169(n - 1);
  endfunction

  function int f_multi169(input bit s);
    if (s) return kg169;
    return lg169;
  endfunction

  function int f_case169(input bit s);
    case (s)
      1'b1: return kg169;
      default: return lg169;
    endcase
  endfunction

  function void f_void169(); return; endfunction

  task t_task169(); return; endtask

  function int f_after169();
    int q;
    q = 1;
    if (q == 0) return lg169;
    return kg169;
  endfunction
endpackage

package p169ig;
  import p169hg::*;
  parameter int owng169 = 6;
  function int f_owng169(); return owng169; endfunction
endpackage

module v169_g_control;
  import p169hg::*;
  import p169ig::*;
  int g_i;
  initial begin
    f_void169();
    t_task169();
    g_i = f_rec169(2) + f_multi169(1'b1) + f_case169(1'b0) + f_after169() +
          f_owng169();
  end
endmodule
