// § bodyTypeParamChainBorrow278
module dut ( input logic [3:0] i, output logic o );
  localparam type a_t = logic [1:0];
  localparam type b_t = a_t [1:0];
  b_t x;
  assign x = i;
  assign o = ^x;
endmodule
