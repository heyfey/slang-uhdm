// § defGenCfcThroughCondSel255 (a module-local struct variable path under a ?:)
module dut (input logic [15:0] d, output logic [1:0] o);
  typedef struct packed { logic [3:0] q; } s_t;
  s_t [1:0] loc;
  struct packed { s_t [1:0] sel; logic [1:0] en; } st;
  assign loc = '0; assign st = '0;
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = st.en[k] ? d[st.sel[k]] : d[loc[k].q];
  end
endmodule
module top; logic [1:0] o; dut u (.d(16'h0), .o(o)); endmodule
