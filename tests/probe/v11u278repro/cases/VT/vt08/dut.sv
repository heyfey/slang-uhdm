// § bodyTypeParamChainBorrow278
module dut ( input logic [2:0] i, output logic o );
  localparam type a_t = logic [2:0];
  localparam type b_t = a_t, c_t = b_t;
  c_t x;
  b_t y;
  assign x = i;
  assign y = x;
  assign o = ^y;
endmodule
