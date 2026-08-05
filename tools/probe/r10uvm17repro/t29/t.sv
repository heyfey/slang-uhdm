// t29 — an OUTPUT / INOUT / REF actual at a call site.  slang models the
// binding of an actual to an output formal as a synthesized AssignmentExpression
// (the copy-back), which the call-argument arm then renders as an
// operation(vpiAssignmentOp); Surelog lists the bare lvalue.  UVM hits it on
// `m_req_fifo.try_get(t)` and friends (~600 rows on SeqDriver).
package p29;

  class Q29;
    int store;
    function bit try_get(output int t);
      t = store;
      return 1;
    endfunction
    function void poke(inout int v);
      v = v + 1;
    endfunction
    function void byref(ref int r);
      r = 5;
    endfunction
  endclass

  class U29;
    Q29 q;
    int t;
    int arr[4];
    function void go();
      int loc;
      // statement-position calls
      void'(q.try_get(t));
      q.poke(t);
      q.byref(loc);
      // condition position
      while (q.try_get(t)) begin
        loc = t;
      end
      if (q.try_get(loc)) begin
        t = loc;
      end
      // an INDEXED output actual
      void'(q.try_get(arr[1]));
    endfunction
  endclass

endpackage : p29

module top29;
  import p29::*;
  U29 u;
  initial begin
    u = new();
    u.go();
  end
endmodule
