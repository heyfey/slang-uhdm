// § tpGroupOneSpan234: the second file
package p;
  import q::*;
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    function void push_rsp(RSP x); endfunction
  endclass
endpackage
