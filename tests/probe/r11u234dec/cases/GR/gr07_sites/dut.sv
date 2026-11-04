// § tpGroupOneSpan234: every holder: fixed / dynamic / associative properties, a method local, a nested-block local, a return value
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ fx[2];
    RSP dy[];
    REQ as[string];
    function RSP last_rsp(); RSP l; begin REQ n; n = null; end return l; endfunction
    function void push_req(REQ x); endfunction
  endclass
endpackage
