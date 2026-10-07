// § pkgNetNamedTsDimEnd280
// an interface with a port typed by the package typedef and a local array
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v [0:1];
endpackage
interface ifc(input pk::st_t ip);
  pk::st_t loc [2];
endinterface
module top(input pk::st_t i); ifc u(.ip(i)); endmodule
