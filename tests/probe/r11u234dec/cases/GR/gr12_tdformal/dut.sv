// § tpGroupOneSpan234: only typedef-spelled formals (not writers): the header default's token
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(req_type x); endfunction
    function void push_rsp(rsp_type y); endfunction
  endclass
endpackage
