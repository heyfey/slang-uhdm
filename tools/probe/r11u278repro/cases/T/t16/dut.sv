// § bodyTypeParamChainBorrow278
package pk; typedef logic [1:0] a_t; endpackage
module dut import pk::*; ( output logic o );
  localparam type a_t = logic [1:0];
  localparam type b_t = a_t;
  b_t x;
  assign x = '0;
  assign o = ^x;
endmodule
