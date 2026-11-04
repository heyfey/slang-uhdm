// § caSelLhsParamReuseAnyEnc301
package pk;
  localparam int Z = 5;
endpackage
module m ();
  logic [7:0] arr[2];
  assign arr[0] = pk::Z;
endmodule
module dut;
  m u_a();
endmodule
