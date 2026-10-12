// § caFillPackedAggElabSharesDef301
module m #(parameter int N = 2) (output logic [15:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t [N-1:0] q;
  assign q = '1;
  assign o = q;
endmodule
module dut (output logic [15:0] o);
  m u (.o(o));
endmodule
