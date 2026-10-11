// § ternSgnLitFreshIntTs284
package pk;
  localparam bit C = 1'b1;
endpackage
module dut(output logic [31:0] o);
  localparam int T = pk::C ? 6'so77 : 6'so1;
  assign o = T;
endmodule
