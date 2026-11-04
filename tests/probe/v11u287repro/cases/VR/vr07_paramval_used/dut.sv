// § pvRecvBodyParamTs287
interface itf #(parameter int A = 16, parameter int B = 32) (); logic [A-1:0] a; modport m (input a); endinterface
module leaf (itf.m p, output logic [31:0] o);
  localparam int A = 5;
  assign o = A;
endmodule
module dut (output logic [31:0] o); itf #(8, 32) arr[2] (); leaf u (.p(arr[0]), .o(o)); endmodule
