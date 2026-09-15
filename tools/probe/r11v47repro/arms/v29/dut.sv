module unused_def #(parameter type it_t = struct packed { logic [7:0] x; logic [3:0] y; });
  localparam it_t I = '{x: 8'd1, y: 4'd2};
endmodule
module dut;
  logic a;
  initial a = 1'b0;
endmodule
