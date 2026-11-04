// § psBoundPathFirstMember154
interface tif; localparam int W = 3; logic [7:0] d; modport sub(input d); endinterface
module m(tif.sub sub, output logic [7:0] o); assign o = sub.d[sub.W:0]; endmodule
module top(output logic [7:0] o); tif t(); m u(.sub(t.sub), .o(o)); endmodule
