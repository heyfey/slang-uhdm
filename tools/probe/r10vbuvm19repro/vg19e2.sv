// vbuvm19 adversarial grid E — class-qualified / super-qualified headers,
// for-init assignments, method-call negatives, queue `$` index.
package vep19;
  class vbase19; int z19; endclass

  class ve19;
    static vbase19 sa19[int];
    vbase19 pa19[int];
    vbase19 pq19[$];
    int     pf19[4];
    extern function void clsq19();
    extern function void mcall19();
    extern function void dollar19();
  endclass

  class vf19 extends ve19;
    extern function void suphdr19();
  endclass

  // 1 — header written CLASS-QUALIFIED on a static property, bare assignment
  function void ve19::clsq19();
    foreach (ve19::sa19[i]) $display("cq", ve19::sa19[i]);
    sa19[0] = null;
  endfunction

  // 2 — the ancestor statement is a METHOD CALL, not an assignment (negative)
  function void ve19::mcall19();
    foreach (pa19[i]) $display("mc", pa19[i]);
    pa19.delete(0);
  endfunction

  // 3 — a queue select assignment written with the `$` index
  function void ve19::dollar19();
    foreach (pq19[i]) $display("dl", pq19[i]);
    pq19[$] = null;
  endfunction


  // 5 — header written `super.`-qualified, bare assignment
  function void vf19::suphdr19();
    foreach (super.pa19[i]) $display("sh", pa19[i]);
    pa19[1] = null;
  endfunction
endpackage
