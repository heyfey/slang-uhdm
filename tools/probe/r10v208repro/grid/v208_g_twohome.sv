// r10v208 arm G — TWO HOME DECLARATIONS, ONE CLONE, and a SECOND typedef of the
// same width alongside, so a wrong element type cannot ride along unnoticed.
// The home's two `foreach`-walked declarations and the clone's declaration all
// share one memoised chain in the elaborated listing: the widest corpus shape
// (`get_physical_addresses`, five home co-owners) in miniature.
package p208a_vg;
  typedef bit [7:0]  bt208vg;
  typedef bit [15:0] wt208vg;
  function automatic int fh1208vg(input int n208);
    bt208vg h1208[];
    wt208vg w1208[];
    int a208 = 0;
    foreach (h1208[i208]) a208 += int'(h1208[i208]);
    foreach (w1208[j208]) a208 += int'(w1208[j208]);
    return a208 + n208;
  endfunction
  function automatic int fh2208vg(input int n208);
    bt208vg h2208[];
    int a208 = 0;
    foreach (h2208[i208]) a208 += int'(h2208[i208]);
    return a208 + n208;
  endfunction
  function automatic int fcl208vg(input int n208);
    bt208vg c1208[];
    wt208vg c2208[];
    int a208 = 0;
    foreach (c1208[i208]) a208 += int'(c1208[i208]);
    foreach (c2208[j208]) a208 += int'(c2208[j208]);
    return a208 + n208;
  endfunction
endpackage

package p208b_vg;
  import p208a_vg::*;
  function automatic int gb208vg();
    return fh1208vg(1) + fh2208vg(2) + fcl208vg(3);
  endfunction
endpackage

module v208_g_twohome;
  import p208b_vg::*;
  int r208;
  initial r208 = gb208vg();
endmodule
