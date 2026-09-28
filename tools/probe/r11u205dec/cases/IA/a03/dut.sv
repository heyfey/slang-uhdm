// r11u205 IA a03: indexed by a localparam, module scope
interface bi;
  logic w;
endinterface
module dut(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = 1'b1;
  assign o = b[0].w;
endmodule
