module dut #(parameter int W = 8,
             parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; })
            (input logic a_i, output logic [7:0] b_o);
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  assign b_o = a_i ? I.x : I.y;
endmodule
