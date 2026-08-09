// r10uvm28 t38c — the NESTING axis of § classMethodNoBind.
//
// The largest remaining reference-binding residue is 1359 EXTRA bindings per
// UVM test: references we bind and golden leaves bare.  Its head is
// `uvm_scope_stack::get`'s `if (v != "" && ...)`, whose operand golden leaves
// unbound even though the identical shape at a method's TOP level (t38a
// `if (lb == 0)`) binds on both sides.  The one structural difference is that
// the UVM occurrence sits inside a `for` loop body.  Each method below repeats
// the same two binding windows — an if CONDITION and a user-call ARGUMENT —
// at a different statement nesting depth, over a bare local, an initialised
// local, a string local and a formal.
package pk;

  class c;
    int p;

    function void top(int a);
      int lb;
      int li = 1;
      string sv;
      if (lb == 0) p = 1;
      if (li == 0) p = 2;
      if (sv == "") p = 3;
      if (a == 0) p = 4;
      mm(lb);
      mm(a);
    endfunction

    function void in_for(int a);
      int lb;
      int li = 1;
      string sv;
      for (int k = 0; k < 2; k++) begin
        if (lb == 0) p = 1;
        if (li == 0) p = 2;
        if (sv == "") p = 3;
        if (a == 0) p = 4;
        mm(lb);
        mm(a);
      end
    endfunction

    function void in_while(int a);
      int lb;
      string sv;
      while (p < 2) begin
        if (lb == 0) p = 1;
        if (sv == "") p = 3;
        mm(lb);
        mm(a);
      end
    endfunction

    function void in_begin(int a);
      int lb;
      string sv;
      begin
        if (lb == 0) p = 1;
        if (sv == "") p = 3;
        mm(lb);
        mm(a);
      end
    endfunction

    function void in_if(int a);
      int lb;
      string sv;
      if (p == 0) begin
        if (lb == 0) p = 1;
        if (sv == "") p = 3;
        mm(lb);
        mm(a);
      end
    endfunction

    function void in_foreach(int a);
      int lb;
      int arr[4];
      foreach (arr[i]) begin
        if (lb == 0) p = 1;
        mm(lb);
        mm(a);
      end
    endfunction

    // the exact uvm_scope_stack::get shape: a string local assigned in a for
    // body and tested in a compound condition there
    function string uvmshape();
      string v;
      string st[$];
      for (int i = 0; i < 2; i++) begin
        v = st[i];
        if (v != "" && (v[0] == "[" || v[0] == "("))
          uvmshape = {uvmshape, v};
        else
          uvmshape = {uvmshape, ".", v};
      end
    endfunction

    function void mm(int z);
    endfunction
  endclass

endpackage

module top;
  pk::c h;
  initial begin
    h = new();
    h.top(1);
    h.in_for(1);
    h.in_while(1);
    h.in_begin(1);
    h.in_if(1);
    h.in_foreach(1);
    void'(h.uvmshape());
  end
endmodule
