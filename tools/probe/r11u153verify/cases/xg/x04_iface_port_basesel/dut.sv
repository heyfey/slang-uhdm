// § constPathBaseAnyKind146 § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
interface bus_if #(parameter int W = 2);
  s_t [W-1:0] sd;
endinterface
module m(bus_if b, output logic o);
  assign o = b.sd[b.W-1].v;
endmodule
module top(output logic o);
  bus_if #(.W(2)) s();
  m u(.b(s), .o(o));
endmodule
