// § clsInModTdLastWriter462
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
endpackage
module m #(parameter int K = 1);
  import p::*;
  class C;
    s_t f;
  endclass
  s_t v;
endmodule
module top;
  for (genvar g = 0; g < 2; g++) begin : gb
    m #(.K(g)) u();
  end
endmodule
