// r10uvm205 arm B — THE CONTEXTS.  The same array-of-package-typedef
// declaration in every place a clone body can hold one: the subroutine's own
// level, a `begin` block, a `for` body, a `foreach` body, a FORMAL, a function
// RETURN variable (§ 16's measured exception) and a class PROPERTY (outside
// every body).
package p205a_c;
  typedef bit [7:0] bt205;
  typedef bt205 arr205[];

  class D205;
    bt205 dprop205[];
    extern function int dm205(input bt205 dio205[]);
  endclass

  function int D205::dm205(input bt205 dio205[]);
    bt205 dtop205[];
    int   s205 = 0;
    begin
      bt205 dblk205[];
      s205 += dblk205.size();
    end
    for (int i205 = 0; i205 < 2; i205++) begin
      bt205 dfor205[];
      s205 += dfor205.size();
    end
    foreach (dio205[j205]) begin
      bt205 dfe205[];
      s205 += dfe205.size() + int'(dio205[j205]);
    end
    return s205 + dtop205.size() + dprop205.size();
  endfunction

  function automatic arr205 fret205();
    arr205 rv205;
    return rv205;
  endfunction

  function automatic int fctx205(input bt205 cio205[]);
    bt205 ctop205[];
    int   s205 = 0;
    begin
      bt205 cblk205[];
      s205 += cblk205.size();
    end
    return s205 + ctop205.size() + cio205.size() + fret205().size();
  endfunction
endpackage

package p205b_c;
  import p205a_c::*;
  function automatic int gc205();
    bt205 z205[];
    D205 d205;
    d205 = new();
    return fctx205(z205) + d205.dm205(z205);
  endfunction
endpackage

module g205_b_ctx;
  import p205b_c::*;
  int r205;
  initial r205 = gc205();
endmodule
