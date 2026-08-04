`define WW 8
package p1;
  parameter int W = 8;
  typedef bit [W-1:0] bt;
  typedef logic [W-1:0] lt;
  typedef bit unsigned [`WW-1:0] mt;
  class C;
    function void cm(input bt a[3]); endfunction
    function void cq(ref bt q[$]); endfunction
    function void cmm(input mt am[3]); endfunction
  endclass
  function automatic void pf(ref bt a[]); endfunction
  function void pf2(input bt b); endfunction
  function void pf3(input lt c[2]); endfunction
  function void pfm(input mt am[2]); endfunction
  function void pfm2(input mt bm); endfunction
endpackage

package p2;
  import p1::*;
  function void q1(input bt a[2]); endfunction
  function void q2m(input mt am[2]); endfunction
endpackage

module top;
  import p1::*;
  bt m[];
  initial pf(m);
endmodule
