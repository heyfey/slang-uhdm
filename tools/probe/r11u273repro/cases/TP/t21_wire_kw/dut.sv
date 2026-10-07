// § typeParamStructLastNetParent273
module dut (input logic a_i, output logic [7:0] b_o);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  wire it_t v;
  assign v = '{x: 8'd1, y: {7'd0, a_i}};
  assign b_o = v.y;
endmodule
