module sub #(parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; })
           (input logic a_i, output it_t o);
  assign o = '{x: 8'd1, y: 8'd2};
endmodule
module dut (input logic a_i, output logic [15:0] b_o);
  sub u0 (.a_i(a_i), .o(b_o));
endmodule
