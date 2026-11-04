// § untypedDepUnboundedValue489
module top(output logic [7:0] o); for (genvar i = 0; i < 2; i++) begin : g localparam B = 4'd15 + 4'd1; end assign o = g[0].B; endmodule
