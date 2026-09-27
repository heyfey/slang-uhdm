// § modAggTfArgCloneFollows180
module top (input logic [31:0] i, output logic [11:0] o);
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  logic [11:0] r;
  task automatic t (input op_t op); r = op.f; endtask
  always_comb t(i);
  assign o = r;
endmodule
