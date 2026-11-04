// § bodyTypeParamChainBorrow278
program pg;
  localparam type a_t = logic [2:0];
  localparam type b_t = a_t;
  b_t x;
endprogram
module dut ( output logic o ); assign o = 1'b0; endmodule
