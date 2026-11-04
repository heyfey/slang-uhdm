// § untypedDepUnboundedValue489
package p; localparam B = 4'd15 + 4'd1; endpackage
module top(output logic [7:0] o); assign o = p::B; endmodule
