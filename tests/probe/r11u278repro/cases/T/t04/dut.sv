// § bodyTypeParamChainBorrow278
module dut ( input logic [3:0] i, output logic o );
  localparam type a_t = logic [3:0];
  localparam type b_t = a_t;
  localparam type c_t = b_t;
  c_t x;
  assign x = i;
  assign o = ^x;
endmodule
