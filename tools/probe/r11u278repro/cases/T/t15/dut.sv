// § bodyTypeParamChainBorrow278
program prg;
  localparam type a_t = logic [2:0];
  localparam type b_t = a_t;
  b_t x;
endprogram
module dut; prg p(); endmodule
