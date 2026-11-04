// § caSelLhsParamReuseAnyEnc301
package p;
  localparam int PZ = 6;
endpackage
module m ();
  import p::*;
  logic [7:0] v;
  assign v[3:0] = PZ;
endmodule
module dut;
  m u_a();
endmodule
