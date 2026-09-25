// § constPathBaseAnyKind146
typedef struct packed { int unsigned w; int unsigned d; } cfg_t;
interface bus_if #(parameter cfg_t C = '{w: 8, d: 2});
  logic [C.w-1:0] x;
endinterface
module m(bus_if b, input logic [b.C.w-1:0] din, output logic [7:0] o);
  assign o = din;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  bus_if s();
  m u(.b(s), .din(i), .o(o));
endmodule
