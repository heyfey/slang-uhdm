package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
interface iface15 import q::*; ();
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
endinterface
module v15 (output logic [7:0] o);
  iface15 i();
  assign o = i.A;
endmodule
