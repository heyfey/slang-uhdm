// r11u205 IA a01: an interface-array element member as a module-scope target, indexed by an enum constant (InterfArrayBind's shape)
interface bi;
  logic w;
endinterface
module dut(output logic o);
  enum logic [0:0] { E0 } e;
  bi b[2]();
  assign b[E0].w = 1'b1;
  assign o = b[0].w;
endmodule
