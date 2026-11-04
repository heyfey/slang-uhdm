// § hpLvSelIdxNamesByPath224
interface ifc(input logic [1:0] i, input logic [1:0] d);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  always_comb begin
    s = '0;
    s.arr[i][1:0] = d;
  end
endinterface
module top(input logic [1:0] i, input logic [1:0] d);
  ifc u(i, d);
endmodule
