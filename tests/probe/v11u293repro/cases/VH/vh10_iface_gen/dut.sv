// § pkgHoistArrNetElemDimSpan293
// An interface importer reading the array in a generate block.
package pk;
  typedef struct packed { logic [3:0] a; logic b; } st_t;
  st_t v [0:1];
endpackage
interface ifc (output logic o);
  import pk::*;
  if (1) begin : g
    assign o = v[1].b;
  end
endinterface
module top (output logic o);
  ifc u_if (.o(o));
endmodule
