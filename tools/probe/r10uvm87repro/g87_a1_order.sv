// r10uvm87 arm 1 — typedef ORDER, count, and the formal's written spelling,
// for a class-scope TYPE PARAMETER group whose resolved type is a CLASS.
package p87a;
  class base87; int x; endclass
  class alt87;  int y; endclass

  // (a) the UVM shape verbatim: two params, RSP = REQ, typedefs REQ->req_type
  //     then RSP->rsp_type, formal written REQ, method EXTERN + out of body.
  class c_uvm #(type REQ = base87, type RSP = REQ);
    typedef c_uvm #( REQ , RSP) this_type;
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_buf[$];
    extern function void f_ext(REQ item);
    function void f_in(REQ item); endfunction
  endclass
  function void c_uvm::f_ext(REQ item); endfunction

  // (b) SWAPPED typedef order: rsp_type before req_type.
  class c_swap #(type REQ = base87, type RSP = REQ);
    typedef RSP rsp_type;
    typedef REQ req_type;
    extern function void f_ext(REQ item);
  endclass
  function void c_swap::f_ext(REQ item); endfunction

  // (c) ONE typedef only (of the FIRST param).
  class c_one #(type REQ = base87, type RSP = REQ);
    typedef REQ req_type;
    extern function void f_ext(REQ item);
  endclass
  function void c_one::f_ext(REQ item); endfunction

  // (d) NO typedef at all.
  class c_none #(type REQ = base87, type RSP = REQ);
    extern function void f_ext(REQ item);
  endclass
  function void c_none::f_ext(REQ item); endfunction

  // (e) formal written RSP instead of REQ.
  class c_rsp #(type REQ = base87, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    extern function void f_ext(RSP item);
  endclass
  function void c_rsp::f_ext(RSP item); endfunction

  // (f) the two params resolve to DIFFERENT classes.
  class c_two #(type REQ = base87, type RSP = alt87);
    typedef REQ req_type;
    typedef RSP rsp_type;
    extern function void f_ext(REQ item);
  endclass
  function void c_two::f_ext(REQ item); endfunction
endpackage

module top87a;
  p87a::c_uvm  #() u1;
  p87a::c_swap #() u2;
  p87a::c_one  #() u3;
  p87a::c_none #() u4;
  p87a::c_rsp  #() u5;
  p87a::c_two  #() u6;
endmodule
