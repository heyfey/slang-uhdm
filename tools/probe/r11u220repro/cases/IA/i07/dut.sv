// r11u220 decode (no law): InterfArrayBind d, the module-scope interface-array target with a literal right side; the elaborated listing shares the definition cont_assign (ModuleEmit emitContAssigns)
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(input logic x, output logic o);
  enum logic [0:0] { E0 } e;
  bi b[2]();
  assign b[E0].w = x & 1'b1;
  assign o = b[0].w;
endmodule
