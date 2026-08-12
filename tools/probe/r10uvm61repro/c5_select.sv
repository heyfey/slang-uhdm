// r10uvm61 ARM c5_select — does the own-class-property fold extend from a BARE
// NAME to a SELECT or MEMBER-ACCESS rooted at one?
//
// Raised by the corpus, not by theory: after the bare-name law landed, the six
// $bits sites still unfolded in SimpleUVM were all
// `$bits(m_byte_enable[i])` in uvm_tlm_generic_payload::do_record --
// an ElementSelect over an own class property, which golden DOES fold.
// Every row below pairs the select form with its bare-name control, and
// repeats the two negative controls the bare-name law established
// (out-of-block body, inherited member) so an extension cannot quietly widen
// past them.
package c5_pkg;

  typedef struct packed { logic [3:0] a; logic [2:0] b; } st_t;

  class sel_c;
    logic [7:0]  m_pk;
    bit          m_arr[4];
    logic [7:0]  m_parr[4];
    st_t         m_s;
    st_t         m_sarr[2];
    int          m_q[$];
    int          m_dyn[];
    int          m_i;

    function void r(ref int o, input int i);
      o = $bits(m_pk);           // control: bare name, folds
      o = $bits(m_pk[2]);        // bit select of a packed member
      o = $bits(m_pk[3:0]);      // range select, constant bounds
      o = $bits(m_pk[i +: 2]);   // indexed part select, VARIABLE base
      o = $bits(m_arr[i]);       // element select, unpacked, VARIABLE index
      o = $bits(m_arr[1]);       // element select, unpacked, CONSTANT index
      o = $bits(m_parr[i]);      // element select -> packed element
      o = $bits(m_s.a);          // member access into a packed struct member
      o = $bits(m_sarr[i].b);    // select THEN member access
      o = $bits(m_q[i]);         // element select of a QUEUE
      o = $bits(m_dyn[i]);       // element select of a DYNAMIC array
    endfunction
  endclass

  // NEGATIVE CONTROL 1: the same selects in an OUT-OF-BLOCK body
  class seloob_c;
    logic [7:0] m_pk;
    bit         m_arr[4];
    extern function void r(ref int o, input int i);
  endclass

  function void seloob_c::r(ref int o, input int i);
    o = $bits(m_pk);
    o = $bits(m_pk[2]);
    o = $bits(m_arr[i]);
  endfunction

  // NEGATIVE CONTROL 2: selects over an INHERITED member
  class selbase_c;
    logic [7:0] m_pk;
    bit         m_arr[4];
  endclass
  class selinh_c extends selbase_c;
    logic [7:0] m_own;
    function void r(ref int o, input int i);
      o = $bits(m_pk[2]);        // inherited
      o = $bits(m_arr[i]);       // inherited
      o = $bits(m_own[2]);       // own -- the positive twin
    endfunction
  endclass

  // NEGATIVE CONTROL 3: a select over a function LOCAL, and over a FORMAL
  class selloc_c;
    logic [7:0] m_pk;
    function void r(ref int o, input int i, input logic [7:0] f_pk);
      logic [7:0] l_pk;
      o = $bits(l_pk[2]);
      o = $bits(f_pk[2]);
      o = $bits(m_pk[2]);        // own -- the positive twin
    endfunction
  endclass

  // NEGATIVE CONTROL 4: a select whose width is PARAMETER-dependent
  class selparm_c #(int W = 8);
    logic [W-1:0] m_dep[4];
    logic [7:0]   m_fix[4];
    function void r(ref int o, input int i);
      o = $bits(m_dep[i]);
      o = $bits(m_fix[i]);
    endfunction
  endclass

endpackage

module c5_top;
  import c5_pkg::*;
  int o;
  initial begin
    sel_c a = new(); seloob_c b = new(); selinh_c c = new();
    selloc_c d = new(); selparm_c#(8) e = new();
    a.r(o, 1); b.r(o, 1); c.r(o, 1); d.r(o, 1, 8'h0); e.r(o, 1);
  end
endmodule
