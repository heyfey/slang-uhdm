// § psBoundPathFirstMember154
interface tif; localparam int HI = 6; localparam int LO = 2; logic [7:0] d; modport sub(input d); endinterface
module m(tif.sub sub, input logic [7:0] v, output logic [4:0] o); assign o = v[sub.HI:sub.LO]; endmodule
module top(input logic [7:0] v, output logic [4:0] o); tif t(); m u(.sub(t.sub), .v(v), .o(o)); endmodule
