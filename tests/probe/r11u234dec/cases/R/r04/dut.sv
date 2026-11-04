// § decode R: r01 with only RSP formals (the chain member written on the formals)
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    RSP m_rsp_buf[$];
    extern function void push_rsp(RSP x);
    extern function void put_rsp(RSP y);
  endclass
  function void base::push_rsp(RSP x); endfunction
  function void base::put_rsp(RSP y); endfunction
endpackage
