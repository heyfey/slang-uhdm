// § pkgPatReadTsNoParent131
// case t04: nested struct pattern parameter read qualified through two member selects in a localparam
package pk;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } in_t;
  typedef struct packed { in_t i; logic [7:0] z; } out_t;
  parameter out_t P = '{i: '{x: 4'd1, y: 4'd2}, z: 8'd3};
endpackage
module top(output logic [3:0] o);
  localparam logic [3:0] L = pk::P.i.y;
  assign o = L;
endmodule
