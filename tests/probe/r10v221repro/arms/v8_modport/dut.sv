// v8_modport — THE InterfaceModPort CANARY FACE in miniature.  The canary is
// an INSTANTIATED-INTERFACE test and must not move; this arm carries modports
// on BOTH an instantiated and an uninstantiated interface with enum constants
// in their subroutine bodies, so a law that reached modport-bearing holders
// through the wrong road would show here before the canary battery runs.
package v8pkg;
  typedef enum logic [1:0] { MP_A = 2'd0, MP_B = 2'd1, MP_C = 2'd2 } mp_e;
endpackage

interface v8_inst_if (input logic clk);
  import v8pkg::*;
  typedef enum logic [2:0] { D_X = 3'd0, D_Y = 3'd1 } d_e;
  logic [2:0] req, rsp;

  function automatic d_e decide(input int k);
    if (k == 0) return D_X;
    case (k)
      1: return D_Y;
      default: return D_X;
    endcase
  endfunction
  function automatic int score(input int k);
    return k + int'(MP_A) + int'(MP_C);
  endfunction

  modport mgr (output req, input rsp, import decide, import score);
  modport sub (input req, output rsp, import decide);
endinterface

interface v8_uninst_if (input logic clk);
  import v8pkg::*;
  typedef enum logic [2:0] { E_X = 3'd0, E_Y = 3'd1 } e_e;
  logic [2:0] req, rsp;

  function automatic e_e decide(input int k);
    if (k == 0) return E_X;
    case (k)
      1: return E_Y;
      default: return E_X;
    endcase
  endfunction
  function automatic int score(input int k);
    return k + int'(MP_B) + int'(MP_C);
  endfunction

  modport mgr (output req, input rsp, import decide, import score);
  modport sub (input req, output rsp, import decide);
endinterface

module v8_top (input logic clk);
  v8_inst_if u_if (.clk(clk));
endmodule
