// r10buvm1 arm a1 — THE RECEIVER-SCOPE x METHOD-KIND x POSITION GRID.
//
// The corpus head is BuildUVMPkg's
//     uvm_pkg::uvm_deferred_init.push_back(rgtry);
// a `::`-QUALIFIED package-variable receiver carrying a BUILT-IN queue method,
// in STATEMENT position, where golden emits ONE bare ref_obj named
// `uvm_pkg::uvm_deferred_init` spanning the QUALIFIER ALONE and drops the
// method AND its argument.
//
// Every cell below is one written form; the grid separates the four axes the
// head confounds:
//   * WHERE the receiver is declared (package / class-static / module / local)
//   * HOW it is written (`pkg::v` / `cls::v` qualified vs bare)
//   * WHAT the method is (built-in queue/string method vs USER class method)
//   * WHERE the call sits (statement vs expression)
// plus non-call suffixes (member access, element select) as positive controls
// for § staticScopedChainDrops48, which already owns those.
package p1;
  class cobj1;
    int v;
    static int sq[$];
    static cobj1 sh;
    function void touch(int n);
      v = n;
    endfunction
    function int peek();
      return v;
    endfunction
  endclass
  int pq[$];
  cobj1 pobj;
  string pstr;
endpackage

module m1;
  import p1::*;
  int mq[$];
  cobj1 mobj;
  int r;

  function automatic int f1();
    int lq[$];
    cobj1 lobj;
    int x;
    lobj = new();
    // ---------------- STATEMENT position ----------------
    p1::pq.push_back(1);
    p1::pobj.touch(2);
    p1::pstr.itoa(3);
    pq.push_back(4);
    pobj.touch(5);
    mq.push_back(6);
    mobj.touch(7);
    lq.push_back(8);
    lobj.touch(9);
    cobj1::sq.push_back(10);
    cobj1::sh.touch(11);
    // ---------------- EXPRESSION position ----------------
    x = p1::pq.size();
    x += p1::pobj.peek();
    x += pq.size();
    x += mq.size();
    x += lq.size();
    x += cobj1::sq.size();
    x += cobj1::sh.peek();
    // ---------------- NON-CALL suffixes on qualified receivers ----------------
    x += p1::pq[0];
    x += p1::pobj.v;
    x += cobj1::sh.v;
    // ---------------- PARENS-LESS built-in on a qualified receiver ----------------
    x += p1::pq.size;
    return x;
  endfunction

  initial r = f1();
endmodule
