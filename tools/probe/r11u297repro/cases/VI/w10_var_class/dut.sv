// § varDeclInitElabSpan297
class C; int a; endclass
module dut (input logic [7:0] pa, output logic o);
  C h0 = null;
  var C h1 = h0;
  assign o = pa[0];
endmodule
