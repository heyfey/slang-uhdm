// § pkgElabUnaryFoldOpSpan274
parameter int UA = -3;
localparam logic [7:0] UB = ~8'h0F;
module dut(output int o, output logic [7:0] p); assign o = UA; assign p = UB; endmodule
