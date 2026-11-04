// § bodyTypeParamChainBorrow278
interface ifc;
  localparam type a_t = logic [4:0];
  localparam type b_t = a_t;
  b_t x;
endinterface
module dut ( output logic o );
  ifc u();
  assign o = ^u.x;
endmodule
