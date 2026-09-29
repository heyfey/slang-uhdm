// § incDecOperandKeepsLvalueForm215 — prefix and postfix operators in a plain function call's arguments
package p;
  class seq; int m_next_id; endclass
  function automatic void set_id(int i, int j = 0); endfunction
  class sqr;
    seq sp;
    function void send();
      set_id(sp.m_next_id++);
      set_id(++sp.m_next_id);
      set_id(--sp.m_next_id, sp.m_next_id--);
    endfunction
  endclass
endpackage
module m;
endmodule
