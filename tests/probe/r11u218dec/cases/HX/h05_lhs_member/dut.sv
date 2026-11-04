// § lhsIdxHierPathElems218 — h05_lhs_member: a plain member as the index
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  typedef struct packed { logic [6:0] addr; logic [31:0] data; } req_t;
endpackage
module m(input dm::req_t req, output logic [127:0][31:0] o);
  logic [127:0][31:0] data_d;
  always_comb begin : rw
    data_d = '0;
    data_d[req.addr] = req.data;
  end
  assign o = data_d;
endmodule
module top(input dm::req_t req, output logic [1:0][31:0] o);
  m u(.req(req), .o(o));
endmodule
