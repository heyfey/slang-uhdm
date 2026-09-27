package p;
class seq;
  int m_id;
endclass
class drv;
  seq sp;
  function void f();
    sp.m_id++;
    sp.m_id--;
    ++sp.m_id;
  endfunction
endclass
endpackage
module top; endmodule
