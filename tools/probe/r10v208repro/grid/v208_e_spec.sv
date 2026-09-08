// r10v208 arm E — uvm202's FACE: a PARAMETERIZED CLASS SPECIALIZATION reached
// through a wildcard import, whose method declares an array of the package
// typedef and walks it with foreach.  uvm202's committed model is that golden
// SHARES a specialization; § 208 must not split anything there, and must not
// move the home cells.
package p208a_ve;
  typedef bit [7:0] bt208ve;
  class C208ve #(int W208 = 4);
    function int walk208(input int n208);
      bt208ve arr208[];
      int a208 = 0;
      foreach (arr208[i208])
        a208 += int'(arr208[i208]);
      return a208 + n208 + W208;
    endfunction
  endclass
  function automatic int fh208ve(input int n208);
    bt208ve hm208[];
    int a208 = 0;
    foreach (hm208[i208])
      a208 += int'(hm208[i208]);
    return a208 + n208;
  endfunction
endpackage

package p208b_ve;
  import p208a_ve::*;
  function automatic int gb208ve();
    C208ve #(8) c208;
    c208 = new();
    return c208.walk208(1) + fh208ve(2);
  endfunction
endpackage

package p208c_ve;
  import p208a_ve::*;
  function automatic int gc208ve();
    C208ve #(8) c208;
    c208 = new();
    return c208.walk208(3) + fh208ve(4);
  endfunction
endpackage

module v208_e_spec;
  import p208b_ve::*;
  import p208c_ve::*;
  int r208;
  initial r208 = gb208ve() + gc208ve();
endmodule
