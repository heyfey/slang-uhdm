// § tpGroupOneSpan234: a package-qualified default (type REQ = q::item)
package q;
  class item; endclass
endpackage
package p;
  class base #(type REQ = q::item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    function void push_rsp(RSP x); endfunction
  endclass
endpackage
