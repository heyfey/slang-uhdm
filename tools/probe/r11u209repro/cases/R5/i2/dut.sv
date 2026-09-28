// § defGenTargetIpsDefName205: an if-generate assignment target with a descending indexed part select
typedef struct packed { logic [7:0] f; logic v; } s_t;
module top #(parameter bit P = 1) (input logic [3:0] i, output s_t o);
  assign o.v = 1'b1;
  assign o.f[3:0] = 4'd0;
  if (P) begin : gen_q
    assign o.f[7-:4] = i;
  end
endmodule
