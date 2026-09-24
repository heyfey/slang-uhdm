module dut #(parameter type a_t = struct packed { logic [7:0] x; logic [7:0] y; },
             parameter type b_t = a_t)
            (input logic a_i, output logic [7:0] b_o);
  localparam b_t I = '{x: 8'd1, y: 8'd2};
  assign b_o = a_i ? I.x : I.y;
endmodule
