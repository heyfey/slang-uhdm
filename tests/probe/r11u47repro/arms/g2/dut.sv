module dut #(parameter int W = 8) (input logic a_i, output logic [W-1:0] b_o);
  localparam type it_t = union packed {
    logic [W-1:0] x;
    logic [W-1:0] y;
  };
  localparam it_t I = it_t'(8'd3);
  assign b_o = a_i ? I.x : I.y;
endmodule
