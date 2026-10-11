// § pvPatFlattenTsUnparented287
package r; typedef struct packed { int unsigned DAT; logic [7:0] B; } bus_t; localparam bus_t BDEF = '{DAT: 32, B: 8'h5}; endpackage
interface tif #(parameter r::bus_t CFG = r::BDEF); logic d; modport mp (input d); endinterface
module leaf (tif.mp q); logic z; assign z = q.d; endmodule
module top; tif u(); leaf a0 (u.mp); endmodule
