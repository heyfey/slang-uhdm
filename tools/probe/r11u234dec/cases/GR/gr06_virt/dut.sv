// § tpGroupOneSpan234: a virtual class with a pure virtual prototype, a static method and a task writing the group
package p;
  class item; endclass
  virtual class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_one;
    static function void s(REQ x); endfunction
    task t(input RSP y); endtask
    pure virtual function void pv(RSP z);
  endclass
endpackage
