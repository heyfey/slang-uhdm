// vbuvm5 ADVERSARIAL arm v2 -- THE SELECT-TRACKING INTERACTION.
//
// The patch does not only skip `ref->Actual_group(it->second)`; it also moved
// the `selWholeRefs` / `selWholeWrittenVars` registration INSIDE the same
// `if`.  `selWholeWrittenVars` is a PER-VARIABLE set consulted by endSelTrack
// for OTHER references to the same variable, so dropping an entry for a
// SUPPRESSED reference can change what a DIFFERENT, still-bound reference
// re-points to.  These cells are built to fire exactly that path.
//
// The `ref_var` population used here is a class-nested typedef of a PACKED
// VECTOR spelled BARE inside an OUT-OF-BODY method -- the only ref_var local
// that can carry a part-select.
package qs;

  class owns;
    typedef logic [7:0] bs_t;
    protected int nums[$];

    extern function void s01s(int ns);
    extern function void s02s(int ns);
    extern function void s03s(int ns);
    extern function void s04s(int ns);
    extern function void s05s(int ns);
  endclass

  function void isinks(logic [7:0] as); endfunction

  // s01 -- whole write + CONSTANT-bounds part-select write + a call-arg read.
  // endSelTrack's `selWholeWrittenVars` carve-out is what keeps the call-arg
  // read pointing at the ref_var instead of at the part_select.  The whole
  // write is an ASSIGNMENT LHS, which the new predicate SUPPRESSES -- so it
  // never lands in selWholeWrittenVars any more.
  function void owns::s01s(int ns);
    bs_t bs;
    bs = 8'h00;
    bs[3:0] = 4'hf;
    isinks(bs);
  endfunction

  // s02 -- CONTROL: same, but with NO whole write at all
  function void owns::s02s(int ns);
    bs_t bs;
    bs[3:0] = 4'hf;
    isinks(bs);
  endfunction

  // s03 -- whole write + INDEXED part-select write + a call-arg read
  function void owns::s03s(int ns);
    bs_t bs;
    bs = 8'h00;
    bs[ns +: 4] = 4'hf;
    isinks(bs);
  endfunction

  // s04 -- whole write + constant part-select write, read in an ASSIGNMENT RHS
  // (the read itself is suppressed by the new predicate)
  function void owns::s04s(int ns);
    bs_t bs;
    logic [7:0] cs;
    bs = 8'h00;
    bs[3:0] = 4'hf;
    cs = bs;
  endfunction

  // s05 -- whole write + constant part-select write, read in an IF CONDITION
  function void owns::s05s(int ns);
    bs_t bs;
    bs = 8'h00;
    bs[3:0] = 4'hf;
    if (bs == 8'h0f) nums.push_back(1);
  endfunction

endpackage
