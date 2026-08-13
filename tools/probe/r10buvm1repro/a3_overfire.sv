// r10buvm1 arm a3 — THE OVER-FIRE GUARD for § scopedBuiltinRecvIsChain1.
//
// The new law reaches a built-in method's receiver through `arguments()[0]`,
// which is EXACTLY where a real system task/function keeps its FIRST ARGUMENT.
// Every cell here is a call slang models as a SystemSubroutine with a null
// `thisClass()` and a `::`-scoped expression sitting at argument 0, or a
// `::`-rooted receiver whose SYMBOL KIND § staticScopedChainDrops48 excludes.
// If the law fires on any of them it has eaten a call it does not own.
package p3;
  typedef enum {E0, E1} e3_t;
  parameter int PARR[2] = '{1, 2};
  int pq[$];
  int parr3[];
  string pstr3;
  class c3;
    rand int rv;
    int w;
  endclass
  c3 pobj3;
endpackage

module m3;
  int z;
  string s;
  int hits;
  function automatic int f3();
    int y;
    int lq[$];
    // ---- $-named system calls whose ARGUMENT 0 is a `::`-scoped chain ----
    $display("%0d", p3::pq.size());
    $display("%0d", p3::PARR[0]);
    y = $bits(p3::pq);
    // ---- built-in method on a receiver kind the collapse must NOT own ----
    s = p3::E1.name();
    y += $size(p3::PARR);
    // ---- built-in method whose receiver is UNSCOPED (control, must not move) --
    lq.push_back(1);
    y += lq.size();
    // ---- a `::`-scoped chain as an ARGUMENT of an unscoped built-in method ----
    lq.push_back(p3::pq[0]);
    // ---- with-clause built-in on a scoped receiver ----
    y += p3::pq.sum() with (item);
    // ---- scoped receiver, dynamic-array built-in, statement position ----
    p3::parr3.delete();
    // ---- scoped receiver, string built-in, expression position ----
    y += p3::pstr3.len();
    // ---- scoped class-handle receiver, built-in randomize ----
    if (p3::pobj3.randomize()) hits++;
    return y;
  endfunction
  initial z = f3();
endmodule
