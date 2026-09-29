// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  task automatic t(input logic [1:0] ii);
    s.arr[ii][1:0] = d;
  endtask
  always_comb begin
    s = '0;
    t(i);
  end
  assign o = s;
endmodule
