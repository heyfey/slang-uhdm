package p;
class seq;
  int m_next_transaction_id;
endclass
class drv;
  seq sequence_ptr;
  function int f();
    return sequence_ptr.m_next_transaction_id++;
  endfunction
endclass
endpackage
module top; endmodule
