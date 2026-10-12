// § varDeclInitElabSpan297
module dut (input logic [7:0] pa, output logic o);
  typedef bit [7:0] v_t;
  var v_t x = 8'h12;
  assign o = x[0] ^ pa[0];
endmodule
