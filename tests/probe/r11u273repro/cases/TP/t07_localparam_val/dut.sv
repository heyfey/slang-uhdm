// § typeParamStructLastNetParent273
module dut (input logic a_i, output logic [7:0] b_o);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  assign b_o = a_i ? I.x : I.y;
endmodule
