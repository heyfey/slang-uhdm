// § paramInitUnpackedMemberPath154
package p; typedef struct { int unsigned DAT; int unsigned ADR; } bus_t; endpackage
module m #(parameter p::bus_t C = '{DAT: 32, ADR: 8}) (output logic [7:0] o);
  localparam int unsigned X = C.DAT/8 + C.ADR;
  assign o = X;
endmodule
module top(output logic [7:0] o); m u(o); endmodule
