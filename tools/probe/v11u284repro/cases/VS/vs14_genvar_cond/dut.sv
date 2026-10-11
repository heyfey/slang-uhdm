// § ternSgnLitFreshIntTs284
module dut(output logic [31:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam int T = (k == 0) ? 2'sb10 : 2'b01;
    assign o[k] = T;
  end
endmodule
