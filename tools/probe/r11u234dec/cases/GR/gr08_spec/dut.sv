// § tpGroupOneSpan234: the generic class beside two specializations used by a package variable
package p;
  class item; endclass
  class item2 extends item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    function void push_rsp(RSP x); endfunction
  endclass
  base #(item2) b1;
  base #(item, item2) b2;
endpackage
