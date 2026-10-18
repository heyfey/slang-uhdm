// § undefaultedDefInvalidInst404
module dut #(parameter els_p) (input [$clog2(els_p)-1:0] sel, output logic [els_p-1:0] y);
  always_comb begin
    y = '0;
    y[sel] = 1'b1;
  end
endmodule
module top; endmodule
