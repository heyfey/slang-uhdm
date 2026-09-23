typedef struct packed { logic a; logic b; } s_t;
module dut #(parameter type id_t = s_t, localparam type rt_t = id_t [1:0]) (output logic [3:0] o);
  rt_t x = '0;
  assign o = x;
endmodule
