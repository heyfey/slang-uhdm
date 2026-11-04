// § modAliasTdAtBaseClone484 (module alias declared inside a generate block)
module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  if (1) begin : g
    typedef op_t op2_t;
    op2_t w;
    assign w = i;
    assign o = w.a;
  end
endmodule
