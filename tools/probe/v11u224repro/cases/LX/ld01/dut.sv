// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] d, output logic [32:0] o);
  typedef enum logic [1:0] { E0, E1, E2, E3 } e_t;
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  always_comb begin
    s = '0;
    s.arr[E2][1:0] = d;
  end
  assign o = s;
endmodule
