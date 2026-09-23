module dut #(parameter type T = struct packed { logic [2:0] a; logic b; }, localparam int W = $bits(T)) (input T i, output logic [W-1:0] o);
  assign o = i;
endmodule
