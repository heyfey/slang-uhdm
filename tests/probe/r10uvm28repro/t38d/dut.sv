// r10uvm28 t38d — the cell t38c left out, and the one that REFUTED the
// "control bodies bind nothing" reading of t38c.
//
// t38c measured only CONDITIONS and CALL ARGUMENTS inside a loop/arm and found
// both bare, so pass 28 briefly modelled a control body as a no-bind region.
// The UVM says otherwise: `uvm_component::lookup`'s `comp = top;`, an
// ASSIGNMENT inside an `if` body, binds BOTH operands in golden — while the
// same assignment at a method's top level (t38a `lb = a;`) binds neither.  So
// the axis is not "does this position bind" alone; each position must be
// measured at each nesting depth.  This file is that grid.
package pk;

  class c;
    int p;
    int q;

    function void tops(int a);
      int lb;
      int lc;
      lb = a;          // assignment, TOP level
      lc = lb;
      p = lb;
      q = a;
    endfunction

    function void in_if_asg(int a);
      int lb;
      int lc;
      if (p == 0) begin
        lb = a;        // assignment, inside an if body
        lc = lb;
        p = lb;
      end
    endfunction

    function void in_for_asg(int a);
      int lb;
      int lc;
      for (int k = 0; k < 2; k++) begin
        lb = a;        // assignment, inside a for body
        lc = lb;
      end
    endfunction

    function void in_while_asg(int a);
      int lb;
      int lc;
      while (p < 2) begin
        lb = a;
        lc = lb;
      end
    endfunction

    function void in_begin_asg(int a);
      int lb;
      int lc;
      begin
        lb = a;
        lc = lb;
      end
    endfunction

    // conditions and call arguments at the SAME depths, for the 2x2
    function void in_if_cond(int a);
      int lb;
      if (p == 0) begin
        if (lb == 0) q = 1;
        mm(lb);
        mm(a);
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
    h.tops(1);
    h.in_if_asg(1);
    h.in_for_asg(1);
    h.in_while_asg(1);
    h.in_begin_asg(1);
    h.in_if_cond(1);
  end
endmodule
