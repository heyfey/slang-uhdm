// § hpOpIdxNestedSelByPath304
interface ifc;
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
endinterface
module m (ifc p, input logic [1:0] k, output logic [7:0] o);
  always_comb o = p.ea[k[0] + 1].fld;
endmodule
module top (input logic [1:0] k, output logic [7:0] o);
  ifc u ();
  m mm (.p(u), .k(k), .o(o));
endmodule
