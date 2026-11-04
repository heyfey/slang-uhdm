// § hpLvSelIdxNamesByPath224
module top #(parameter int P = 2) (input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  localparam int L = 1;
  always_comb begin
    s = '0;
    s.arr[P][1:0] = d;
    s.arr[L][3:2] = d;
  end
  assign o = s;
endmodule
