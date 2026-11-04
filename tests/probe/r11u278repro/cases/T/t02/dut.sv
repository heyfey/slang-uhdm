// § bodyTypeParamChainBorrow278
module dut ( input logic [1:0] i, output logic o );
  parameter type a_t = logic [1:0];
  parameter type b_t = a_t;
  b_t w;
  assign w = i;
  assign o = ^w;
endmodule
