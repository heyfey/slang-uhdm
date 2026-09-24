// r10v208 arm F — THE IO_DECL FACE.  § 208's owner masks read `io_decl`
// typespecs as well as `variables`.  A subroutine whose FORMAL is an array of
// the package typedef, wildcard-imported, beside a home body that walks the
// same element type with foreach so the chain is shared (mask 3).
package p208a_vf;
  typedef bit [7:0] bt208vf;
  function automatic int fio208vf(input bt208vf a208[], input int n208);
    int s208 = 0;
    foreach (a208[i208])
      s208 += int'(a208[i208]);
    return s208 + n208;
  endfunction
  function automatic int fh208vf(input int n208);
    bt208vf hm208[];
    int a208 = 0;
    foreach (hm208[i208])
      a208 += int'(hm208[i208]);
    return a208 + n208;
  endfunction
endpackage

package p208b_vf;
  import p208a_vf::*;
  function automatic int gb208vf();
    bt208vf z208[];
    return fio208vf(z208, 1) + fh208vf(2);
  endfunction
endpackage

module v208_f_io;
  import p208b_vf::*;
  int r208;
  initial r208 = gb208vf();
endmodule
