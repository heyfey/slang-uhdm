// § pvRecvBodyParamTs287
interface itf #(parameter int A = 16) (); logic [A-1:0] a; modport m (input a); endinterface
module leaf (itf.m p); localparam int A = 5; endmodule
module dut (); itf #(8) i0 (); leaf u (.p(i0)); endmodule
