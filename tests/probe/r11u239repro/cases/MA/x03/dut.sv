// § modportArgVarFormalTs239
// packed struct and enum members
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
  assign o = f_pk(bif.pk) & f_k(bif.kind);
  function automatic logic f_pk(logic [7:0] p);
    return p == '0;
  endfunction
  function automatic logic f_k(logic [1:0] k);
    return k == '0;
  endfunction
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter #(.AW(8)) u (.bif(b), .o(o));
endmodule
