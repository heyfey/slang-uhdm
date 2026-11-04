// § patMemberSizeCastSignedInt435
module child #(parameter int K = 9) (input logic a_i, output logic [31:0] b_o);
  localparam type it_t = struct packed { logic [31:0] x; logic [31:0] y; };
  localparam it_t I = '{x: 32'(K), y: 32'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
module dut(input logic a_i, output logic [31:0] o, output logic [31:0] p);
  child #(.K(-4)) u1(.a_i(a_i), .b_o(o));
  child u2(.a_i(a_i), .b_o(p));
endmodule
