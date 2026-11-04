// § incDecOperandKeepsLvalueForm215 — a postfix increment of a handle's member as a METHOD call's argument (BuildUVMPkg's send_request shape)
package p;
  class seq; int m_next_id; endclass
  class req; function void set_id(int i); endfunction endclass
  class sqr;
    seq sequence_ptr;
    function void send(req param_t);
      param_t.set_id(sequence_ptr.m_next_id++);
      param_t.set_id(sequence_ptr.m_next_id--);
    endfunction
  endclass
endpackage
module m;
endmodule
