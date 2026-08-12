// r10uvm61 ARM c2_context — the CONTEXT axis.  c1 established the class-body
// rule; this asks whether the same fold happens OUTSIDE a class at all:
// module function, task, always, initial, continuous assign, module-level
// actual, and a package (non-class) function.
//
// Operand is always a plain variable whose width is statically known.
package c2_pkg;
  int p_v;
  // P1: a PACKAGE function (no class anywhere) on a package variable
  function int p_f();
    return $bits(p_v);
  endfunction
  // P2: a package function on its OWN local
  function int p_g();
    int l_v;
    return $bits(l_v);
  endfunction
endpackage

module c2_top;
  import c2_pkg::*;

  bit         m_b;         // module-level 1-bit
  logic [7:0] m_v;         // module-level 8-bit
  int         o1, o2, o3, o4, o5, o6, o7;
  wire [31:0] w;

  // M1: MODULE FUNCTION on a module-level variable
  function int m_f();
    return $bits(m_v);
  endfunction

  // M2: MODULE FUNCTION on its own local
  function int m_g();
    logic [7:0] l_v;
    return $bits(l_v);
  endfunction

  // M3: MODULE TASK on a module-level variable
  task m_t(output int o);
    o = $bits(m_v);
  endtask

  // M4: ALWAYS block, module-level variable
  always_comb o1 = $bits(m_v);

  // M5: INITIAL block, module-level variable
  initial o2 = $bits(m_v);

  // M6: CONTINUOUS ASSIGN
  assign w = $bits(m_v);

  // M7: module-level PARAMETER initialiser
  localparam int LP = $bits(m_v);

  // M8: a packed-dimension bound
  logic [$bits(m_v)-1:0] m_dim;

  // M9: module-level variable initialiser
  int m_init = $bits(m_v);

  initial begin
    o3 = m_f(); o4 = m_g(); m_t(o5); o6 = p_f(); o7 = p_g();
  end
endmodule
