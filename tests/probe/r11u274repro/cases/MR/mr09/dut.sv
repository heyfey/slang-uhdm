// § elabMemberReadCopyChain274
typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
interface ifc #(parameter s_t P = '{a: 1, b: 2}) (); logic [7:0] v; assign v = P.a; endinterface
module kid #(parameter s_t P = '{a: 3, b: 4}) (output logic [7:0] o);
  ifc #(.P(P)) i0 ();
  always_comb o = i0.v + P.b;
endmodule
module dut(output logic [7:0] o); kid k0 (.o(o)); endmodule
