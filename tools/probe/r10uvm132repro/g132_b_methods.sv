// r10uvm132 arm B — METHODS x POSITION under the PASTED macro: `size` in an
// expression (a while-condition), `push_back` / `pop_front` / `delete` in
// statement position, and a USER method reached the same way.
`include "g132_defs.svh"

module top_b132;
  class cls_b132;
    string qm1_132[$];
    string qm2_132[$];
    string qm3_132[$];

    function void g132_user(string v);
      qm3_132.push_back(v);
    endfunction

    function void run_b132();
      `G132_QDA(QUEUE, qm1_132)
      `G132_QDA2(QUEUE, qm2_132, "t")
      `G132_QDAU(QUEUE, this, "u")
    endfunction
  endclass

  cls_b132 h_b132;
endmodule
