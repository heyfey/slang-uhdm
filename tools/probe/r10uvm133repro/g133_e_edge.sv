// r10uvm133 arm E - the NEAR MISSES of the call rule.  MEASUREMENT ONLY.
// LHS is always golden (Surelog).
package p133_e;
  typedef struct packed { bit [7:0] hi; bit [3:0] lo; } se133_t;

  class inner133_c;
    int iv;
    function int gi133(); return 1; endfunction
  endclass

  class edge133_c;
    int          eq[$];
    string       es;
    bit [15:0]   ev;
    bit [7:0]    ea [4];
    se133_t      esm;
    inner133_c   ec;

    function int ef133(); return 2; endfunction
    function int eidx133(); return 1; endfunction

    function void probe133();
      int r;
      r = $bits(eq.size);              // E01 method call written WITHOUT ()
      r = $bits(this.eq.size());       // E02 this-qualified receiver
      r = $bits(ec.gi133());           // E03 chained receiver, class handle
      r = $bits(ec.iv);                // E04 chained MEMBER (no call)
      r = $bits(ef133() + 1);          // E05 binary op, call leftmost
      r = $bits(1 + ef133());          // E06 binary op, call rightmost
      r = $bits(-ef133());             // E07 unary op over a call
      r = $bits(int'(ef133()));        // E08 cast over a call
      r = $bits({ef133(), ef133()});   // E09 concatenation of calls
      r = $bits(ea[eidx133()]);        // E10 select whose INDEX is a call
      r = $bits(ev[eidx133()]);        // E11 bit-select whose index is a call
      r = $bits($clog2(4));            // E12 system call argument
      r = $bits(es.len());             // E13 string method call
      r = $bits(esm.hi);               // E14 member access (no call)
      r = $bits(eq[0]);                // E15 queue element select
      if (r == 0) r = 1;
    endfunction
  endclass
endpackage
