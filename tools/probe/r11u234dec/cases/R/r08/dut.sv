// § decode R: a single type parameter with a typedef naming it and one formal
package p;
  class item; endclass
  class base #(type REQ = item);
    typedef REQ req_type;
    REQ m_req_buf[$];
    REQ m_one;
    function void push_req(REQ x); endfunction
  endclass
endpackage
