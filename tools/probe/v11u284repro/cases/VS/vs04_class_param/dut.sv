// § ternSgnLitFreshIntTs284
package pc;
  class K #(parameter bit C = 1'b0);
    localparam int T = C ? 1'b0 : 2'sb10;
  endclass
endpackage
module dut(output logic [31:0] o);
  assign o = pc::K#()::T;
endmodule
