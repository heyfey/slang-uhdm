// § wireScopedTdPkgOnly305v
class C;
  typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
endclass
module top (input logic [5:0] t, output logic [2:0] o);
  wire C::sa_t sn;
  assign sn = t;
  assign o = sn.a;
endmodule
