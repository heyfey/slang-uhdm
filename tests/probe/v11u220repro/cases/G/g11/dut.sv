// § hpVarSelRangeIdxNamesByPath220
module sub #(parameter int N = 2) (input logic [32:0] din, output logic [N*2-1:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  assign s = din;
  for (genvar a = 0; a < N; a++) begin : ga
    for (genvar b = 0; b < 2; b++) begin : gb
      if (b == 0) begin : gi
        assign o[a*2+b] = ^s.arr[a+b][b:0];
      end else begin : ge
        assign o[a*2+b] = |s.arr[a][b+1:b];
      end
    end
  end
endmodule
module mid(input logic [32:0] din, output logic [3:0] o);
  sub #(.N(2)) u(.din(din), .o(o));
endmodule
module top(input logic [32:0] din, output logic [3:0] o);
  mid m(.din(din), .o(o));
endmodule
