// r10uvm193 ARM B — THE METHOD AXIS of § cloneArrayRecvArgMintsElemVar193.
//
// MEASUREMENT ONLY.  One real Surelog golden, both views.  LHS is ALWAYS
// golden.
//
// The producer asks NOTHING about the method: it fires on any
// `method_func_call` whose parent is a `hier_path` and whose receiving element
// is bound to an `array_var`.  The corpus proves that outright — four of its
// ten cells are `visited.exists(succ)`, a BUILT-IN associative-array method,
// and six are `regs[j].get_address(this)` / `mems[j].get_address(0,this)` /
// `vregs[j].get_address(0,this)`, a USER-DEFINED class method reached through
// an array ELEMENT.  This arm writes every method face side by side so the
// claim "the method does not matter" is a measured column and not a reading of
// the source.

package Dock193;

  class Bollard193;
    int m_ring193;
    function new(); m_ring193 = 0; endfunction
    function int moor193(input int cleat193);
      return cleat193 + m_ring193;
    endfunction
    function int berth193(input int cleat193, input int warp193);
      return cleat193 + warp193 + m_ring193;
    endfunction
  endclass

  // B1  exists   — built-in, ASSOCIATIVE, argument 0.
  function automatic int b1_exists193(input int fml_a193);
    int tackle193[int];
    int kink193;
    kink193 = 1;
    tackle193[kink193] = 4;
    if (tackle193.exists(kink193)) fml_a193 = fml_a193 + 1;
    return fml_a193;
  endfunction

  // B2  delete   — built-in, ASSOCIATIVE, argument 0, VOID/statement position.
  function automatic int b2_delete193(input int fml_b193);
    int tackle193[int];
    int kink193;
    kink193 = 2;
    tackle193[kink193] = 5;
    tackle193.delete(kink193);
    return fml_b193 + tackle193.num();
  endfunction

  // B3  num / size — built-in with NO argument at all: the producer's loop
  //     never runs, so there is nothing to mint.
  function automatic int b3_num193(input int fml_c193);
    int tackle193[int];
    int rope193[$];
    tackle193[1] = 1;
    rope193.push_back(2);
    return fml_c193 + tackle193.num() + rope193.size();
  endfunction

  // B4  first / next — built-in with a REF argument.
  function automatic int b4_first193(input int fml_d193);
    int tackle193[int];
    int kink193;
    tackle193[3] = 3;
    kink193 = 0;
    if (tackle193.first(kink193)) fml_d193 = fml_d193 + kink193;
    if (tackle193.next(kink193)) fml_d193 = fml_d193 + 1;
    return fml_d193;
  endfunction

  // B5  find_index with — an ITERATOR argument, not a `Tf_call_args` name.
  function automatic int b5_find193(input int fml_e193);
    int rope193[$];
    int hits193[$];
    rope193.push_back(7);
    hits193 = rope193.find_index with (item > 3);
    return fml_e193 + hits193.size();
  endfunction

  // B6  a USER-DEFINED method reached through an ARRAY ELEMENT — the corpus's
  //     own `regs[j].get_address(this)` shape, at argument 0 and argument 1.
  function automatic int b6_user193(input int fml_f193);
    Bollard193 fleet193[$];
    int        kink193;
    int        warp193;
    Bollard193 one193;
    one193 = new();
    fleet193.push_back(one193);
    kink193 = 0;
    warp193 = 5;
    return fml_f193 + fleet193[kink193].moor193(warp193)
                    + fleet193[kink193].berth193(1, warp193);
  endfunction

  // B7  the SAME user method on a NON-array receiver: a plain class handle.
  //     Nothing here is this law's, and nothing may move.
  function automatic int b7_handle193(input int fml_g193);
    Bollard193 lone193;
    int        warp193;
    lone193 = new();
    warp193 = 6;
    return fml_g193 + lone193.moor193(warp193);
  endfunction

  // B8  a built-in STRING method on a plain string — § 184's cell, which must
  //     keep binding the RECEIVER.
  function automatic string b8_string193(input int fml_h193);
    string cable193;
    int    kink193;
    cable193 = "hawser";
    kink193 = 2;
    return cable193.substr(1, kink193);
  endfunction

endpackage

package Wharf193;
  import Dock193::*;
  function automatic int haul193(input int fml_i193);
    return fml_i193;
  endfunction
endpackage

module top193b;
  import Dock193::*;
  int r193;
  initial begin
    r193 = b1_exists193(1) + b2_delete193(2) + b3_num193(3) + b4_first193(4)
         + b5_find193(5) + b6_user193(6) + b7_handle193(7) + Wharf193::haul193(9);
  end
endmodule
