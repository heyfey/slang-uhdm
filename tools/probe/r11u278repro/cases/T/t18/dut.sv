// § bodyTypeParamChainBorrow278
module dut ( input logic [2:0] i, output logic o );
  localparam type a_t = logic [2:0];
  localparam type b_t = a_t;
  localparam type c_t = a_t;
  b_t x; c_t y;
  assign x = i; assign y = i;
  assign o = ^{x, y};
endmodule
