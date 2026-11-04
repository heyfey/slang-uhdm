// § pkgNetNamedTsDimEnd280
// an interface importing the package (the importer's copies)
package pk;
  typedef struct packed { logic [7:0] a; } st_t;
  st_t v [0:1];
endpackage
interface ifc;
  import pk::*;
  logic [7:0] w;
endinterface
module top(output logic [7:0] o);
  ifc u();
  assign u.w = 8'd1;
  assign o = u.w;
endmodule
