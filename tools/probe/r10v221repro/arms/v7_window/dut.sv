// v7_window — § 218's OWN ADMITTED CELLS, beside enum constants.  Pass 218
// re-opened the class-method BINDING WINDOW inside an uninstantiated
// interface: variables named there bind (uninstIfaceWindowBind218 ->
// netMap).  Pass 221 declines enum constants in the SAME body through the SAME
// flag.  The two must not collide: every 218 window cell must still bind, and
// every enum cell beside it must go bare.  Class methods IN and OUT of the
// body, since 218's window law distinguishes them.
package v7pkg;
  typedef enum logic [1:0] { W_A = 2'd0, W_B = 2'd1 } w_e;
endpackage

interface v7_if (input logic clk);
  import v7pkg::*;
  typedef enum logic [2:0] { T_X = 3'd0, T_Y = 3'd1 } t_e;
  logic [2:0] sig;
  int         cnt;

  // in-body class method: 218's window
  class inner;
    int m;
    function automatic int im(input int k);
      m = k + int'(W_A);          // enum const BESIDE a class member
      return m + int'(T_X);
    endfunction
  endclass

  // plain subroutine: variables + enums together
  function automatic int f_win(input int k);
    cnt = k;                       // interface VARIABLE — 218's window face
    sig = T_Y;                     // interface VARIABLE assigned an enum
    if (sig == T_X) cnt = int'(W_B);
    return cnt + int'(T_Y);
  endfunction

  task automatic t_win(output int o);
    o = cnt + int'(W_A);
  endtask
endinterface

// A top module so the design HAS a top — an interface with a PORT LIST in a
// design with no top-level module segfaults BOTH binaries (pre-existing; see
// the verifier README residue V-R1).  It instantiates NOTHING, so every
// interface above stays UNINSTANTIATED.
module v7_window_top (input logic clk);
endmodule
