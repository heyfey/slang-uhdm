// § hpLvSelIdxNamesByPath224
package p;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
endpackage
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  always_comb begin
    p::s.arr[i][1:0] = d;
  end
  assign o = p::s;
endmodule
