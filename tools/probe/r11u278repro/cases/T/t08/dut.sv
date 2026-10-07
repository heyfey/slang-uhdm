// § bodyTypeParamChainBorrow278
module dut ( output logic o );
  localparam type a_t = struct packed { logic p; logic q; };
  localparam type b_t = a_t;
  b_t x;
  assign x = '0;
  assign o = x.p;
endmodule
