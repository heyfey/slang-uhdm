// r10uvm61 ARM c1_scope — THE DISCRIMINATOR the corpus census pointed at:
// does golden's $bits fold depend on whether the METHOD is defined INSIDE the
// class body or OUT-OF-BLOCK (`extern` + `Class::method`)?
//
// Every row asks the SAME question -- $bits(<a class member>) -- and differs
// ONLY in where the method body is written.  Same member, same type, same
// call.  If the corpus law is right, IN-BLOCK folds and OUT-OF-BLOCK does not.
package c1_pkg;

  class inblock_c;
    bit        m_b;      // 1 bit
    int        m_i;      // 32 bits
    // R1: method written INSIDE the class body
    function void r1(ref int o);
      o = $bits(m_b);
      o = $bits(m_i);
    endfunction
  endclass

  class oob_c;
    bit        m_b;
    int        m_i;
    // R2: method DECLARED here, DEFINED out-of-block below
    extern function void r2(ref int o);
  endclass

  function void oob_c::r2(ref int o);
    o = $bits(m_b);
    o = $bits(m_i);
  endfunction

  class local_c;
    bit m_b;
    // R3: in-block, but the operand is a FUNCTION LOCAL, not a member
    function void r3(ref int o);
      bit  l_b;
      int  l_i;
      o = $bits(l_b);
      o = $bits(l_i);
      o = $bits(m_b);   // control: a member in the SAME body
    endfunction
  endclass

  class formal_c;
    bit m_b;
    // R4: in-block, operand is a FORMAL argument
    function void r4(input bit f_b, input int f_i, ref int o);
      o = $bits(f_b);
      o = $bits(f_i);
      o = $bits(m_b);   // control
    endfunction
  endclass

  class type_c;
    bit m_b;
    typedef logic [11:0] tw_t;
    // R5: in-block, operand is a TYPE, not a variable
    function void r5(ref int o);
      o = $bits(byte);
      o = $bits(tw_t);
      o = $bits(m_b);   // control
    endfunction
  endclass

  class param_c;
    bit m_b;
    parameter int P = 7;
    localparam int LP = 9;
    // R6: in-block, operand is a PARAMETER / LOCALPARAM of the class
    function void r6(ref int o);
      o = $bits(P);
      o = $bits(LP);
      o = $bits(m_b);   // control
    endfunction
  endclass

  class agg_c;
    bit          m_arr[4];      // UNPACKED array of bit
    logic [7:0]  m_pk;          // packed
    int          m_q[$];        // queue
    inblock_c    m_h;           // class HANDLE
    // R7: in-block, aggregate / handle operands
    function void r7(ref int o);
      o = $bits(m_arr);
      o = $bits(m_pk);
      o = $bits(m_h);
    endfunction
  endclass

  class inh_c extends inblock_c;
    // R8: in-block method whose operand is an INHERITED member
    function void r8(ref int o);
      o = $bits(m_b);
      o = $bits(m_i);
    endfunction
  endclass

  class this_c;
    bit m_b;
    // R9: in-block, operand written with an explicit `this.` prefix
    function void r9(ref int o);
      o = $bits(this.m_b);
    endfunction
  endclass

endpackage

module c1_top;
  import c1_pkg::*;
  int o;
  initial begin
    inblock_c a = new(); oob_c b = new(); local_c c = new();
    formal_c d = new(); type_c e = new(); param_c f = new();
    agg_c g = new(); inh_c h = new(); this_c i = new();
    a.r1(o); b.r2(o); c.r3(o); d.r4(1'b0, 0, o);
    e.r5(o); f.r6(o); g.r7(o); h.r8(o); i.r9(o);
  end
endmodule
