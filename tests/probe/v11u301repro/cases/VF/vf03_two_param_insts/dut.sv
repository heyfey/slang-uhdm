// § caFillPackedAggElabSharesDef301
module m #(parameter int N = 2) (output logic [7:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  s_t [N-1:0] q;
  assign q = '1;
  assign o = 8'(q);
endmodule
module dut (output logic [15:0] o);
  m #(.N(1)) u0 (.o(o[7:0]));
  m #(.N(2)) u1 (.o(o[15:8]));
endmodule
