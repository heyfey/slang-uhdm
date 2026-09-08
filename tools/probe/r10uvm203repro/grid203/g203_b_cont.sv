// r10uvm203 grid arm B — the CONTAINER shapes at package scope and in the
// module's materialized copy: the three DYNAMIC containers against the
// unpacked aggregates that stay dropped.
package pb203;
  class Cb203;
    int v;
  endclass
  Cb203  b_assoc [string];               // associative — golden materializes
  Cb203  b_que   [$];                    // queue
  Cb203  b_dyn   [];                     // dynamic array
  int    b_fixed [4];                    // fixed-size unpacked — still dropped
  typedef struct { int a; int b; } ub203_t;
  ub203_t b_ustruct [2];
  int    b_plain = 7;
  string b_str = "s";
endpackage

import pb203::*;

module gb203;
  bit clk;
endmodule
