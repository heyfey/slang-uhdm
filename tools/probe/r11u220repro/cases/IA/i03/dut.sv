// r11u220 decode (no law): InterfArrayBind d, the module-scope interface-array target with a literal right side; the elaborated listing shares the definition cont_assign (ModuleEmit emitContAssigns)
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(input logic x, output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = x;
  assign o = b[0].w;
endmodule
