// r10uvm87 arm 2 — WHICH DECLARATION SITES join the class-scope type-parameter
// typespec group.  Every class here declares the SAME two-parameter group
// (typedefs req_type then rsp_type -> the winner is rsp_type) and differs only
// in WHERE the parameter name is written.
package p87b;
  class it87; int x; endclass
  class ot87; int y; endclass

  // (a) every VARIABLE spelling: scalar property, queue, dynamic, fixed,
  //     assoc, method body local, nested-block local, and a return type.
  class c_sites #(type REQ = it87, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ p_scalar;
    REQ p_queue[$];
    REQ p_dyn[];
    REQ p_fix[4];
    REQ p_assoc[string];
    function void m_local();
      REQ l_v;
      begin
        REQ l_nested;
      end
    endfunction
    function REQ m_ret();
      return null;
    endfunction
    function void m_formal(REQ item); endfunction
  endclass

  // (b) NO typedef anywhere: is the property still renamed?
  class c_notd #(type REQ = it87, type RSP = REQ);
    REQ p_scalar;
    REQ p_queue[$];
    function void m_formal(REQ item); endfunction
  endclass

  // (c) the parameter default is a NON-CLASS type.
  typedef struct packed { int a; } st87_t;
  typedef enum { E0, E1 } en87_t;
  class c_int #(type REQ = int, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ p_scalar;
    REQ p_queue[$];
    function void m_formal(REQ item); endfunction
  endclass
  class c_str #(type REQ = st87_t, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ p_scalar;
    function void m_formal(REQ item); endfunction
  endclass
  class c_enum #(type REQ = en87_t, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ p_scalar;
    function void m_formal(REQ item); endfunction
  endclass

  // (d) a TYPEDEF OF the parameter written as the property's type.
  class c_tduse #(type REQ = it87, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    req_type p_td;
    rsp_type p_td2;
    function void m_formal(req_type item); endfunction
  endclass

  // (e) a NON-parameterized class: nothing to group.
  class c_plain;
    typedef it87 req_type;
    it87 p_scalar;
    function void m_formal(it87 item); endfunction
  endclass

  // (f) an OVERRIDDEN specialization used from a module below.
  class c_spec #(type REQ = it87, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ p_scalar;
    REQ p_queue[$];
    function void m_formal(REQ item); endfunction
  endclass

  // (g) a DERIVED class using the BASE's parameter (declared there, not here).
  class c_deri extends c_spec #(ot87);
    REQ p_scalar;
  endclass
endpackage

module top87b;
  p87b::c_sites #() a1;
  p87b::c_notd  #() a2;
  p87b::c_int   #() a3;
  p87b::c_str   #() a4;
  p87b::c_enum  #() a5;
  p87b::c_tduse #() a6;
  p87b::c_plain     a7;
  p87b::c_spec #(p87b::ot87) a8;
  p87b::c_deri      a9;
endmodule
