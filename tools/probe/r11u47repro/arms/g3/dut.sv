module dut (input logic a_i, output logic [1:0] b_o);
  localparam type it_t = enum logic [1:0] { EA = 2'd1, EB = 2'd2 };
  localparam it_t I = EA;
  assign b_o = a_i ? I : 2'd0;
endmodule
