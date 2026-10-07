// § pkgNetNamedTsDimEnd280
// two packages each with its own st_t and an array of it
package pa;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v [0:1];
endpackage
package pb;
  typedef struct packed { logic [1:0] a; } st_t;
  st_t v [0:2];
  st_t w;
endpackage
module top(output logic [3:0] o); assign o = pa::v[0].a ^ pb::v[1].a; endmodule
