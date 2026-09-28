// § tfFormalTdCloneFile196: a typedef of a typedef, a scalar bit typedef and an unpacked formal from a header, used by a class method and a module function
package p;
`include "types.svh"
  class c;
    function automatic alias_t m(input alias_t x, input sb_t s, input base_t arr [2]);
      return s ? x : arr[0];
    endfunction
  endclass
endpackage
module top(input logic [5:0] a, output logic [5:0] o);
  import p::*;
  function automatic alias_t mf(input alias_t x);
    return x;
  endfunction
  assign o = mf(a);
endmodule
