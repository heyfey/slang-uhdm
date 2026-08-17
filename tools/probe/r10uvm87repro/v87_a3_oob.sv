// v87 arm a3 — IN-BODY vs OUT-OF-BODY definitions (function, task, ctor).
package p87x;
  class b87; int x; endclass
  class o87 #(type REQ = b87, type RSP = REQ);
    typedef RSP rsp_t;
    extern function void mf(REQ a);
    extern task mt(REQ a);
    extern function o87::REQ mr();
    extern function new(REQ a);
    function void inb(REQ a);
      REQ l_in;
      begin REQ l_in2; l_in2 = l_in; end
    endfunction
  endclass
  function void o87::mf(REQ a);
    REQ l_oob;
    begin REQ l_oob2; l_oob2 = l_oob; end
  endfunction
  task o87::mt(REQ a);
    REQ l_oobt;
    l_oobt = a;
  endtask
  function o87::REQ o87::mr();
    REQ l_r;
    return l_r;
  endfunction
  function o87::new(REQ a);
    REQ l_ctor;
    l_ctor = a;
  endfunction
endpackage

module m87a3;
  import p87x::*;
  o87 #(b87) i0;
  initial begin end
endmodule
