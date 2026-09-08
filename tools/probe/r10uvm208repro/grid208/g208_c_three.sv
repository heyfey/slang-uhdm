// r10uvm208 arm C — THREE IMPORTERS.  The same shape as arm B one importer
// wider, plus a home-side `foreach` over the shared array (the corpus's
// `do_bus_read` face) so the shared chain is reached from a home REFERENCE
// VARIABLE as well as from three clone declarations.  This is the widest
// sharing the corpus has any analogue of; the split must still leave exactly
// ONE qualified home cell standing and bare every clone cell.
package p208a_3;
  typedef bit [7:0] bt208;
  function automatic int f3_208(input int n208);
    bt208 q208[$];
    int   s208 = 0;
    q208.push_back(8'h2);
    foreach (q208[i208])
      s208 += int'(q208[i208]);
    return s208 + n208;
  endfunction
endpackage

package p208b_3;
  import p208a_3::*;
  function automatic int g3b_208();
    return f3_208(1);
  endfunction
endpackage

package p208c_3;
  import p208a_3::*;
  function automatic int g3c_208();
    return f3_208(2);
  endfunction
endpackage

package p208d_3;
  import p208a_3::*;
  function automatic int g3d_208();
    return f3_208(3);
  endfunction
endpackage

module g208_c_three;
  import p208b_3::*;
  import p208c_3::*;
  import p208d_3::*;
  int r208;
  initial r208 = g3b_208() + g3c_208() + g3d_208();
endmodule
