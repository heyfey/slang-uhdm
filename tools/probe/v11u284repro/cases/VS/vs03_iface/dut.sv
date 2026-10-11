// § ternSgnLitFreshIntTs284
interface ifc #(parameter bit C = 1'b0);
  localparam int T = C ? 1'b0 : 4'sh9;
  logic [31:0] o;
  assign o = T;
endinterface
module dut(output logic [31:0] o);
  ifc u();
  assign o = u.o;
endmodule
