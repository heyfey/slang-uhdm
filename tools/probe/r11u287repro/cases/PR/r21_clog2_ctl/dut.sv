// § pvRecvBodyParamTs287
interface itf #(parameter int A = 16) (); logic [A-1:0] a; modport m (input a); endinterface
module leaf #(parameter int N = 100) (itf.m p); localparam int A = $clog2(N); endmodule
module dut (); itf #(8) arr[2] (); leaf u (.p(arr[0])); endmodule
