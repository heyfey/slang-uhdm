// § bodyTypeParamChainBorrow278
module dut #(parameter type T = logic [2:0]) ( input logic [2:0] i, output logic o );
  localparam type b_t = T;
  b_t x;
  assign x = i;
  assign o = ^x;
endmodule
