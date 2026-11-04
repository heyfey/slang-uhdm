// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  task automatic t(output logic [1:0] x); x = 2'b01; endtask
  always_comb begin
    s = '0;
    t(s.arr[i][1:0]);
  end
  assign o = s;
endmodule
