// r10v182 arm G — NAME EDGES and MULTIPLE IMPORTERS.
//  * near-miss names (`sizes`, `Size`, `MAX`, `min_`, `exist`) must stay BARE
//    beside the five that mint — `DeepClone` compares the name EXACTLY.
//  * a receiver whose OWN name is one of the five (`int max [$]; max.size`)
//    must still bind its BASE normally and mint only on the SECOND element.
//  * THREE separate wildcard importers of the same home package produce THREE
//    clone listings of the same function; each must carry its OWN mint.
//  * a user-defined package function literally called `size` must not change
//    what the path element binds to.
//  * a VOID-call statement context and a `$display` argument.
package gable182_home;

  function automatic int size();          // a user function shadowing the name
    return 99;
  endfunction

  function automatic int g_names182_fn();
    int  sluice [$];
    int  sizes  [$];
    int  bay    [$];
    int  hob;
    hob = sluice.size;                  // G_size      IN
    bay = sluice.max;                   // G_max       IN
    bay = sluice.min;                   // G_min       IN
    hob = hob + sizes.size;             // G_sizes_recv (receiver named `sizes`)
    return hob + bay.size;
  endfunction

  function automatic int g_recvname182_fn();
    int max [$];
    int min [$];
    int hob;
    hob = max.size;                     // G_recv_max_size
    hob = hob + min.size;               // G_recv_min_size
    return hob;
  endfunction

  function automatic int g_void182_fn();
    int sluice [$];
    int hob;
    void'(sluice.size);                 // G_void
    $display("%0d", sluice.size);       // G_display
    hob = sluice.size;                  // G_stmt
    return hob;
  endfunction

endpackage

package gable182_i1;
  import gable182_home::*;
  int gable182_a1;
endpackage
package gable182_i2;
  import gable182_home::*;
  int gable182_a2;
endpackage
package gable182_i3;
  import gable182_home::*;
  int gable182_a3;
endpackage

module gable182_top;
  initial begin
    gable182_i1::gable182_a1 = 0;
    gable182_i2::gable182_a2 = 0;
    gable182_i3::gable182_a3 = 0;
  end
endmodule
