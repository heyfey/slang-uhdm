// § defGenTargetIpsDefName205: a for-generate assignment target with an indexed part select on a struct member
typedef struct packed { logic [7:0] f; logic v; } s_t;
module top (input logic [7:0] i, output s_t o);
  assign o.v = 1'b0;
  for (genvar k = 0; k < 4; k++) begin : gen_p
    assign o.f[k*2+:2] = i[k*2+:2];
  end
endmodule
