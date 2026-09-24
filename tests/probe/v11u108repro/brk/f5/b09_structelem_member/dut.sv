typedef struct packed { logic p; logic [1:0] q; } s_t;
module dut #(parameter type id_t = s_t, localparam type rt_t = id_t [1:0]) (input logic [5:0] a, output logic o);
  rt_t x;
  assign x = a;
  assign o = x[1].p ^ x[0].q[1];
endmodule
