// § modAggTfArgCloneFollows180 (control: no formal writer)
module top(output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pr_t;
  localparam pr_t P = '{a: 4'h1, b: 4'h2};
  assign o = P;
endmodule
