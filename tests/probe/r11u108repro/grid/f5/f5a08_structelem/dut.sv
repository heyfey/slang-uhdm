typedef struct packed { logic p; logic q; } s_t;
module dut #(parameter type id_t = s_t, localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
