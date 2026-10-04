// § decode R: r01 with scalar properties instead of queues
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req;
    RSP m_rsp;
    extern function void push_rsp(RSP x);
    extern function void push_req(REQ x);
  endclass
  function void base::push_rsp(RSP x); endfunction
  function void base::push_req(REQ x); endfunction
endpackage
