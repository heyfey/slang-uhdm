// § pvRecvBodyParamTs287
interface itf #(parameter int A = 16) (); logic [A-1:0] a; modport m (input a); endinterface
module leaf (itf.m p); localparam bit [3:0] A = 5; endmodule
module leaf2 (itf.m p); localparam longint A = 7; endmodule
module dut (); itf #(8) arr[2] (); leaf u (.p(arr[0])); leaf2 v (.p(arr[1])); endmodule
