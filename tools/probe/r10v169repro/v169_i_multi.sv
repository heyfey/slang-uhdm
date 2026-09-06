// r10v169 arm I — THREE WILDCARD IMPORTERS OF ONE HOME.  MEASUREMENT ONLY.
// The fold reuses `foldCloneTs`, keyed by the SUBROUTINE SYMBOL, which every
// clone SHARES with its home; widening the fold window to the clone listings
// makes four listings (home DEF + three clone DEFs) reach the same map slot.
// If the widened window splices one listing's object into another's, this is
// the arm that shows it.
package p169hi;
  parameter int     ki169 = 17;
  parameter string  si169 = "eye";
  typedef bit [5:0] vi169_t;
  parameter vi169_t ti169 = 6'h2a;
  function int      f_shared169(); return ki169; endfunction
  function string   f_shstr169();  return si169; endfunction
  function vi169_t  f_shtyp169();  return ti169; endfunction
endpackage

package p169i1;
  import p169hi::*;
  parameter int own1169 = 1;
  function int f_own1169(); return own1169; endfunction
endpackage

package p169i2;
  import p169hi::*;
  parameter int own2169 = 2;
  function int f_own2169(); return own2169; endfunction
endpackage

package p169i3;
  import p169hi::*;
  parameter int own3169 = 3;
  function int f_own3169(); return own3169; endfunction
endpackage

module v169_i_multi;
  import p169hi::*;
  import p169i1::*;
  import p169i2::*;
  import p169i3::*;
  int i_i; string i_s; bit [5:0] i_v;
  initial begin
    i_i = f_shared169() + f_own1169() + f_own2169() + f_own3169();
    i_s = f_shstr169();
    i_v = f_shtyp169();
  end
endmodule
