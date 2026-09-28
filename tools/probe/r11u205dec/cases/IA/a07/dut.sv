// r11u205 IA a07: a local interface instance array target in a for-generate, the right side a non-constant not reading the genvar
interface bi;
  logic w;
endinterface
module dut(input logic x, output logic o);
  bi b[2]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i].w = x;
  end
  assign o = b[0].w;
endmodule
