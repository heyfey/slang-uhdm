// § decode R (N0067 N0068 N0230 N0255): uvm_sequencer_param_base's shape, a class-handle default chained RSP = REQ, typedefs naming both, queue properties and extern prototypes with out-of-body bodies
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    RSP m_rsp_buf[$];
    extern function void push_rsp(RSP x);
    extern function void push_req(REQ x);
  endclass
  function void base::push_rsp(RSP x); endfunction
  function void base::push_req(REQ x); endfunction
endpackage
