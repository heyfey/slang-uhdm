// § lhsIdxHierPathElems218 — h02_rhs_ps: the same hier_path as an index on the RIGHT side
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  typedef struct packed { logic [6:0] addr; logic [31:0] data; } req_t;
endpackage
module m(input dm::req_t req, input logic [1:0][31:0] q, output logic [31:0] o);
  always_comb begin : rw
    o = q[req.addr[0:0]];
  end
endmodule
module top(input dm::req_t req, output logic [1:0][31:0] o);
  m u(.req(req), .o(o));
endmodule
