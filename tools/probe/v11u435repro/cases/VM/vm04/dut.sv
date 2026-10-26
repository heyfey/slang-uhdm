// § patMemberSizeCastUbMask435
module child #(parameter logic [7:0] K = 1) (input logic a_i, output logic [63:0] b_o);
  localparam type it_t = struct packed { logic [63:0] x; logic [63:0] y; };
  localparam it_t I = '{x: 64'(K), y: 64'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
module dut(input logic a_i, output logic [63:0] o, output logic [63:0] p);
  child #(.K(8'sd5)) u1(.a_i(a_i), .b_o(o));
  child #(.K(9)) u2(.a_i(a_i), .b_o(p));
endmodule
