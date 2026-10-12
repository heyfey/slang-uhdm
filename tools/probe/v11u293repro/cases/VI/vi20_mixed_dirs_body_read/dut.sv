// § ifaceLowConnFirstSignal293
// Body-first input and port-first output.
interface ifc (i, o);
  wire [7:0] i;
  input [7:0] i;
  output [7:0] o;
  wire [7:0] o;
  assign o = i + 8'd1;
endinterface
module top (input logic [7:0] i, output logic [7:0] o);
  ifc u_if (.i(i), .o(o));
endmodule
