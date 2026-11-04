// § decode R: r01 without the typedefs (no winning typedef group)
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    REQ m_req_buf[$];
    RSP m_rsp_buf[$];
    extern function void push_rsp(RSP x);
    extern function void push_req(REQ x);
  endclass
  function void base::push_rsp(RSP x); endfunction
  function void base::push_req(REQ x); endfunction
endpackage
