// § patFlatTernPickedLeafSpan250
package p;
  typedef struct packed { integer a; integer b; } s_t;
  localparam s_t dflt = '{a : 3, b : 4};
  localparam s_t ovr = '{a : 9, default : "inv"};
  localparam s_t cfg = '{a: (ovr.a == "inv") ? dflt.a : ovr.a,
                         b: (ovr.b == "inv") ? dflt.b : ovr.b};
endpackage
interface ifc;
  import p::*;
  integer v;
endinterface
module top import p::*; (output integer o);
  ifc i0();
  for (genvar k = 0; k < 2; k++) begin : g
    localparam integer L = k;
  end
  assign o = i0.v;
endmodule
