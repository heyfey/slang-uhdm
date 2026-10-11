// § pvPatFlattenTsUnparented287
package r; typedef struct packed { int unsigned DAT; } bus_t; typedef struct packed { bus_t BUS; } cfg_t;
  localparam cfg_t CDEF = '{BUS: '{DAT: 32}}; endpackage
interface tif #(parameter r::cfg_t CFG = r::CDEF); logic d; modport mp (input d); endinterface
module leaf (tif q); logic z; assign z = q.d; endmodule
module top; tif u(); leaf a0 (.q(u)); endmodule
