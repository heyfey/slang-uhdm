// § paramInitUnpackedMemberPath154
package p; typedef struct { int unsigned DAT; } bus_t; localparam bus_t B_DEF = '{DAT: 16}; endpackage
module mm #(parameter p::bus_t B = p::B_DEF, parameter int unsigned H = B.DAT/2) (output logic [7:0] o);
  assign o = H;
endmodule
module top(output logic [7:0] o); mm u(o); endmodule
