// § paramInitUnpackedMemberPath154
typedef struct { int unsigned DAT; } bus_t;
module m #(parameter bus_t C = '{DAT: 32}) (output logic [C.DAT-1:0] o);
  localparam int unsigned W = C.DAT;
  assign o = W;
endmodule
module top(output logic [31:0] o); m u(o); endmodule
