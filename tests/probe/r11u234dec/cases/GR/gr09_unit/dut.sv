// § tpGroupOneSpan234: a $unit class group
class item; endclass
class base #(type REQ = item, type RSP = REQ);
  typedef REQ req_type;
  typedef RSP rsp_type;
  REQ m_req_buf[$];
  function void push_rsp(RSP x); endfunction
  function void push_req(REQ x); endfunction
endclass
module top; endmodule
