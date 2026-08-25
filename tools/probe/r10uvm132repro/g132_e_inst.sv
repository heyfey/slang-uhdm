// r10uvm132 arm E — INSTANCE COUNT and SPELLING.  The same pasted macro
// invoked ONCE, TWICE and THREE times, over receivers whose names have
// DIFFERENT LENGTHS (the misread's length is the WRITTEN token's, so a
// substituted name of a different length is the case that would move an
// element span if the law took the arm's cumulative offset walk instead of the
// chain's own end locations).
`include "g132_defs.svh"

module top_e132;
  class cls_e132;
    string q1[$];
    string qq_two_132[$];
    string a_very_long_receiver_name_132[$];

    function void one_e132();
      `G132_QDA(QUEUE, q1)
    endfunction

    function void two_e132();
      `G132_QDA(QUEUE, qq_two_132)
      `G132_QDA(QUEUE, q1)
    endfunction

    function void three_e132();
      `G132_QDA(QUEUE, a_very_long_receiver_name_132)
      `G132_QDA(QUEUE, qq_two_132)
      `G132_QDA(QUEUE, q1)
    endfunction
  endclass

  cls_e132 h_e132;
endmodule
