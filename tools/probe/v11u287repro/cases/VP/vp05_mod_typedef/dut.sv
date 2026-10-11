// § pvPatFlattenTsUnparented287
interface tif #(parameter type T = logic, parameter T CFG = '0); logic d; endinterface
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module leaf (tif q); logic z; assign z = q.d; endmodule
module top; tif #(.T(s_t), .CFG('{a: 4'd1, b: 4'd2})) u(); leaf a0 (.q(u)); endmodule
