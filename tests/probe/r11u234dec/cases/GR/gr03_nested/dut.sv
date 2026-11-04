// § tpGroupOneSpan234: a nested class's formal written with an outer parameter name is not a writer
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    class inner;
      function void g(int x); endfunction
    endclass
  endclass
endpackage
