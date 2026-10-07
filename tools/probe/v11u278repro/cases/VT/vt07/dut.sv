// § bodyTypeParamChainBorrow278
module dut ( input logic [2:0] i, output logic o );
  localparam type a_t = logic [2:0];
  localparam type b_t = a_t;
  function automatic b_t f(b_t a); return a ^ 3'b1; endfunction
  assign o = ^f(i);
endmodule
