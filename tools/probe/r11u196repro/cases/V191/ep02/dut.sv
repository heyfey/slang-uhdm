// § enumDefOwnerNotInstance191: an enum imported into an interface and a module, the interface instantiated inside the module
package p;
  typedef enum {X0, X1} e_t;
endpackage
interface bus; import p::*; e_t s; endinterface
module m; import p::*; e_t t; bus b(); endmodule
module top; m u(); endmodule
