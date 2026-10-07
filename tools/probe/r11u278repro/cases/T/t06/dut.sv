// § bodyTypeParamChainBorrow278
typedef logic [1:0] a_t;
module dut ( input logic [1:0] i, output logic o );
  localparam type a_t = logic [1:0];
  localparam type b_t = a_t;
  b_t x;
  assign x = i;
  assign o = ^x;
endmodule
