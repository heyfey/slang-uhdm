// § bodyTypeParamChainBorrow278
module dut ( input logic [2:0] i, output logic o );
  localparam type a_t = logic [2:0];
  localparam type b_t = a_t;
  b_t x [2];
  assign x[0] = i;
  assign x[1] = ~i;
  assign o = ^(x[0] & x[1]);
endmodule
