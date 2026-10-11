// § pvPatFlattenTsUnparented287
package r; typedef struct packed { int unsigned DAT; } bus_t; localparam bus_t BDEF = '{DAT: 32}; endpackage
interface tif #(parameter r::bus_t CFG = r::BDEF); logic d; modport mp (input d); endinterface
module leaf (tif q); logic z; assign z = q.d; endmodule
module top; tif u[2](); leaf a0 (.q(u[1])); endmodule
