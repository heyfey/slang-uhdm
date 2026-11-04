// § decode R: r01 with the last formal written with the class typedef (req_type)
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    RSP m_rsp_buf[$];
    extern function void push_rsp(RSP x);
    function void push_req(req_type x); endfunction
  endclass
  function void base::push_rsp(RSP x); endfunction
endpackage
