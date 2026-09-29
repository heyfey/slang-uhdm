// § hpLvSelIdxNamesByPath224
package p; logic [1:0] k = 2'd1; endpackage
module top(input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  always_comb begin
    s = '0;
    s.arr[p::k][1:0] = d;
  end
  assign o = s;
endmodule
