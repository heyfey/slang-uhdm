// § modportArgVarFormalTs239
// a module bound into the design with bind
interface bus_if #(parameter int AW = 16);
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  logic [AW-1:0] address;
  e_t kind;
  s_t pk;
  logic valid;
  modport slave (input address, input kind, input pk, input valid);
endinterface
module adapter #(parameter int AW = 8) (bus_if.slave bif, output logic o);
  assign o = pre_decode(bif.address);
  function automatic logic pre_decode(logic [AW-1:0] address);
    return address == '0;
  endfunction
endmodule
module chk (bus_if.slave bif, output logic o2);
  assign o2 = f(bif.address);
  function automatic logic f(logic [6:0] a);
    return a == '0;
  endfunction
endmodule
module top (output logic o, output logic o2);
  bus_if #(.AW(8)) b ();
  adapter #(.AW(8)) u (.bif(b), .o(o));
endmodule
bind top chk c (.bif(b), .o2(o2));
