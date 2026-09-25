// § psBoundPathFirstMember154
interface tif; localparam int W = 3; localparam int OFF = 2; logic [7:0] d; modport sub(input d); endinterface
module m(tif.sub sub, input logic [7:0] v, output logic [7:0] o); assign o = v[5:sub.OFF]; endmodule
module top(input logic [7:0] v, output logic [7:0] o); tif t(); m u(.sub(t.sub), .v(v), .o(o)); endmodule
