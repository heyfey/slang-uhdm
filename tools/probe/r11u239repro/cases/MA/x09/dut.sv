// § modportArgVarFormalTs239
// the call in an interface instance's continuous assignment (interface body: not a module) and in a program
interface bus_if #(parameter int AW = 16);
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  logic [AW-1:0] address;
  e_t kind;
  s_t pk;
  logic valid;
  modport slave (input address, input kind, input pk, input valid);
endinterface
interface mon_if (bus_if.slave bif);
  logic seen;
  assign seen = f(bif.address);
  function automatic logic f(logic [6:0] a);
    return a == '0;
  endfunction
endinterface
module adapter #(parameter int AW = 8) (bus_if.slave bif, output logic o);
  mon_if m (.bif(bif));
  assign o = m.seen;
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter #(.AW(8)) u (.bif(b), .o(o));
endmodule
