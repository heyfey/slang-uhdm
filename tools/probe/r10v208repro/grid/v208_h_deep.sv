// r10v208 arm H — DEPTH.  § 208's content key carries a BLOCK DEPTH computed by
// its own `depth208` climb (begin / fork / for / foreach, stopping at the
// subroutine).  The corpus cells sit at depths 1..4; this arm puts the clone's
// declaration at depth 3 inside a nested begin within a for within a begin, and
// the home's sharing reference at depth 0, so a depth mis-count would show up
// as a key collision (refusal) or as an unsplit cell.
package p208a_vh;
  typedef bit [7:0] bt208vh;
  function automatic int fh208vh(input int n208);
    bt208vh top208[];
    int a208 = 0;
    foreach (top208[i208]) a208 += int'(top208[i208]);
    begin
      for (int k208 = 0; k208 < 2; k208++) begin
        begin
          bt208vh deep208[];
          foreach (deep208[j208]) a208 += int'(deep208[j208]);
        end
      end
    end
    return a208 + n208;
  endfunction
endpackage

package p208b_vh;
  import p208a_vh::*;
  function automatic int gb208vh();
    return fh208vh(1);
  endfunction
endpackage

module v208_h_deep;
  import p208b_vh::*;
  int r208;
  initial r208 = gb208vh();
endmodule
