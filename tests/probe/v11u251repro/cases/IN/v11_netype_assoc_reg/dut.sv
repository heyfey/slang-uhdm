// § ifaceDynAliasNetType251 (a reg associative typedef and a logic dynamic typedef in an interface, both definition nets)
typedef reg a_t [int];
typedef logic [2:0] d_t [];
interface ifc;
  a_t a;
  d_t d;
endinterface
module top; ifc i(); endmodule
