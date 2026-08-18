// r10uvm92 ARM a3 — the METHOD-CALL RECEIVER site (SITE 3).  Read off GOLDEN.
// `m_fields[idx-1].get_lsb_pos()` is a hier_path whose NAME is built from the
// RECEIVER path, and its select index goes through the SAME two dispatches.
// The grid crosses: operator/operand kind in the receiver's index x receiver
// depth (1, 2, 3 components) x a NON-operation index (the control that must not
// move) x this./super./plain roots x statement vs expression position.
package v92;
  class base92;
    function int bm(); return 1; endfunction
  endclass
  class item92 extends base92;
    int    fld;
    int    q[$];
    function int gv(); return 2; endfunction
    function int gw(int a); return a; endfunction
  endclass
  class mid92;
    item92 arr[];
    item92 one;
  endclass

  class drv92 extends base92;
    item92 items[];
    mid92  md;
    int    i, j, res;
    int    plain[8];

    function void go();
      // r01 depth 1, operation index (the corpus shape)
      res = items[i-1].gv();
      // r02 depth 1, operation index, other operator
      res = items[i%3].gv();
      // r03 depth 1, index whose operand is a BUILT-IN METHOD call
      res = items[items.size()-1].gv();
      // r04 depth 1, index whose operand is a member access
      res = items[i+md.one.fld].gv();
      // r05 depth 1, NON-operation index -- THE CONTROL, must not move
      res = items[i].gv();
      // r06 depth 1, constant index -- CONTROL
      res = items[2].gv();
      // r07 depth 2, operation index on the LAST component
      res = md.arr[i-1].gv();
      // r08 depth 2, operation index, method WITH an argument
      res = md.arr[i-1].gw(3);
      // r09 depth 2, plain index on the last component -- CONTROL
      res = md.arr[i].gv();
      // r10 this.-rooted receiver, operation index
      res = this.items[i-1].gv();
      // r11 statement position (no return value)
      void'(items[i-1].gv());
      // r12 inherited method through an operation index
      res = items[i*2].bm();
      // r13 nested: index is a select
      res = items[plain[i]].gv();
      // r14 index is a ternary
      res = items[i>0?i:0].gv();
      // r15 index is a concatenation
      res = items[{2'b0,2'b1}].gv();
    endfunction
  endclass
endpackage
