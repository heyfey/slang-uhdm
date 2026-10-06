// § plainMemberIpsOwner264
package tp;
  typedef struct packed { logic v; logic [7:0] a_source; } h2d_t;
endpackage
interface ifc #(parameter int unsigned M = 4) (input tp::h2d_t d);
  localparam int unsigned STIDW = $clog2(M);
  logic [M-1:0] rv;
  for (genvar i = 0; i < M; i++) begin : g
    assign rv[i] = d.a_source[0+:STIDW] == i;
  end
endinterface
module top(input tp::h2d_t d, output logic [3:0] rv);
  ifc #(.M(4)) i(.d(d));
  assign rv = i.rv;
endmodule
