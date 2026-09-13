// v11u7 arm x6 — a member that is a PACKED ARRAY of struct, and a member that
// is itself a packed array, both after a leading aggregate member (the gate
// fires).  `flattenPatternAssignments` unwraps an array_typespec to its
// element typespec (templates/ExprEval.cpp:769-774, 786-791); `flatten7`
// stamps the member typespec whatever kind it is and recurses only on
// struct members.
package q6;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef bus_t [1:0] bus2_t;
  typedef struct packed { bus_t BUS; bus2_t PAIR; logic [3:0] N; } cfg_t;
endpackage
interface xif #(parameter q6::cfg_t CFG = '{BUS: '{DAT: 32},
                                            PAIR: '{'{DAT: 1}, '{DAT: 2}},
                                            N: 4'h3});
  localparam int unsigned W = CFG.BUS.DAT;
  logic [W-1:0] d;
endinterface
module leaf (xif p, output logic o);
  assign o = p.d[0];
endmodule
module top (output logic o);
  xif u ();
  leaf a0 (.p(u), .o(o));
endmodule
