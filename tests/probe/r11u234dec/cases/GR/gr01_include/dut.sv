// § tpGroupOneSpan234: the group's formals in an included file and after it
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
`include "base_protos.svh"
    extern function void push_req(REQ x);
  endclass
  function void base::push_req(REQ x); endfunction
  function void base::push_rsp(RSP x); endfunction
endpackage
