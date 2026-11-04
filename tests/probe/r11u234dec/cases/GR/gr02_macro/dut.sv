// § tpGroupOneSpan234: the last formal written by a macro expansion
`define MK_PUT(NM, TY) function void NM(TY v); endfunction
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    `MK_PUT(put_rsp, RSP)
  endclass
endpackage
