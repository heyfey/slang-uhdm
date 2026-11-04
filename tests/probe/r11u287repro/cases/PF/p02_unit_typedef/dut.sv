// § pvPatFlattenTsUnparented287
typedef struct packed { int unsigned DAT; } bus_t;
interface tif #(parameter bus_t CFG = '{DAT: 32}); logic d; modport mp (input d); endinterface
module leaf (tif q); logic z; assign z = q.d; endmodule
module top; tif u(); leaf a0 (.q(u)); endmodule
