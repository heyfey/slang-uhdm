module dut (input logic a_i, output logic [7:0] b_o);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  it_t v;
  always_comb v = '{x: 8'd1, y: 8'd2};
  assign b_o = a_i ? v.x : v.y;
endmodule
