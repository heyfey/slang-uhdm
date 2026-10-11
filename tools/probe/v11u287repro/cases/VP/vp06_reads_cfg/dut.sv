// § pvPatFlattenTsUnparented287
package r; typedef struct packed { int unsigned DAT; logic [7:0] ADR; } bus_t; localparam bus_t BDEF = '{DAT: 32, ADR: 8'd4}; endpackage
interface tif #(parameter r::bus_t CFG = r::BDEF); logic [31:0] d; modport mp (input d); endinterface
module leaf (tif q, output logic [31:0] o); assign o = q.d + q.CFG.DAT; endmodule
module top(output logic [31:0] o); tif u(); leaf a0 (.q(u), .o(o)); endmodule
