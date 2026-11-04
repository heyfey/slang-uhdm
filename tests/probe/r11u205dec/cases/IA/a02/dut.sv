// r11u205 IA a02: the same target inside a for-generate, indexed by the genvar
interface bi;
  logic w;
endinterface
module dut(output logic o);
  bi b[2]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i].w = 1'b1;
  end
  assign o = b[0].w;
endmodule
