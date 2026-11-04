// § pvRecvBodyParamTs287
interface itf #(parameter int A = 16, parameter int B = 32) (); logic [A-1:0] a; modport m (input a); endinterface
module leaf (itf.m p);
  localparam logic [7:0] A = 5;
endmodule
module dut (); itf #(8, 32) arr[2] (); leaf u (.p(arr[0])); endmodule
