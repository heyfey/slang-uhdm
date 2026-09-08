// v3_muststay — THE SHARPEST TRAP.  An UNINSTANTIATED MODULE is written by
// writeModule (UhdmWriter.cpp:1402-1625), which calls lateBinding at :1575 AND
// :1623 whether or not anything instantiates it — so golden BINDS its enum
// constants even with no instance.  A law that keyed on "nothing instantiates
// this" instead of "this is an INTERFACE nothing instantiates" would break
// here.  writePackage calls it at :1302/:1304 (packages bind too).
// writeProgram (:1795-1900) calls NEITHER — the program rows are the control
// that shows what a genuinely bare holder looks like.
package v3pkg;
  typedef enum logic [1:0] { M_A = 2'd0, M_B = 2'd1, M_C = 2'd2 } m_e;

  // package subroutine — golden BINDS
  function automatic m_e pf(input int k);
    if (k == 0) return M_A;
    case (k)
      1: return M_B;
      default: return M_C;
    endcase
  endfunction
endpackage

// UNINSTANTIATED module — golden BINDS (lateBinding runs in writeModule)
module v3_uninst_mod (input logic clk);
  import v3pkg::*;
  typedef enum logic [2:0] { U_X = 3'd0, U_Y = 3'd1 } u_e;
  function automatic u_e uf(input int k);
    if (k == 0) return U_X;
    return U_Y;
  endfunction
  function automatic m_e uf2(input int k);
    case (k)
      0: return M_A;
      default: return M_B;
    endcase
  endfunction
endmodule

// INSTANTIATED module — golden BINDS
module v3_inst_mod (input logic clk);
  import v3pkg::*;
  typedef enum logic [2:0] { I_X = 3'd0, I_Y = 3'd1 } i_e;
  function automatic i_e mf(input int k);
    if (k == 0) return I_X;
    return I_Y;
  endfunction
endmodule

// PROGRAM — writeProgram calls no late pass (the implementer's R1)
program v3_prog (input logic clk);
  import v3pkg::*;
  typedef enum logic [2:0] { G_X = 3'd0, G_Y = 3'd1 } g_e;
  function automatic g_e gf(input int k);
    if (k == 0) return G_X;
    return G_Y;
  endfunction
endprogram

// a CLASS in a package — the class-method road, untouched by this law
package v3cpkg;
  typedef enum logic [1:0] { C_A = 2'd0, C_B = 2'd1 } c_e;
  class v3_cls;
    function automatic c_e cf(input int k);
      if (k == 0) return C_A;
      return C_B;
    endfunction
  endclass
endpackage

module v3_top (input logic clk);
  v3_inst_mod u_m (.clk(clk));
endmodule
