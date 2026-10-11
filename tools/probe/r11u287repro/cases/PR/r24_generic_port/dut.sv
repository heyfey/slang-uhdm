// § pvRecvBodyParamTs287
interface itf #(parameter int A = 16) (); logic [A-1:0] a; endinterface
module leaf (interface p); localparam int A = 5; endmodule
module dut (); itf #(8) arr[2] (); leaf u (.p(arr[0])); endmodule
