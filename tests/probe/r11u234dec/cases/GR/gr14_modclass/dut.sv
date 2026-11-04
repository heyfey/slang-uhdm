// § tpGroupOneSpan234: the group class declared in a module
module top;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    function void push_rsp(RSP x); endfunction
  endclass
  base b;
endmodule
