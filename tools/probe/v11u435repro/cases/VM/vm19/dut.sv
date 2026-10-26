// § patMemberSizeCastUbMask435
module child #(parameter int W = 32) (input logic a_i, output logic [W-1:0] b_o);
  localparam type it_t = struct packed { logic [W-1:0] x; logic [W-1:0] y; };
  localparam it_t I = '{x: W'(1), y: W'(5)};
  assign b_o = a_i ? I.x : I.y;
endmodule
module dut(input logic a_i, output logic [63:0] o, output logic [31:0] p);
  child #(.W(64)) u1(.a_i(a_i), .b_o(o));
  child u2(.a_i(a_i), .b_o(p));
endmodule
