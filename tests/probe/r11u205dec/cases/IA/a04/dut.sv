// r11u205 IA a04: the element member read on the right side, genvar index
interface bi;
  logic w;
endinterface
module dut(output logic [1:0] o);
  bi b[2]();
  assign b[0].w = 1'b1;
  assign b[1].w = 1'b0;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = b[i].w;
  end
endmodule
