typedef struct packed { logic [1:0] p; logic q; } e_t;
module dut #(parameter type T = struct packed { e_t e; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
