// § ternSgnLitFreshIntTs284
package pk;
  localparam bit C = 1'b0;
  localparam int T = C ? 1'sb0 : 1'sb1;
endpackage
module dut(output logic [31:0] o);
  assign o = pk::T;
endmodule
