// § modportArgVarFormalTs239
// generic interface port, modport named at the connection
interface bus_if #(parameter int AW = 16);
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  logic [AW-1:0] address;
  e_t kind;
  s_t pk;
  logic valid;
  modport slave (input address, input kind, input pk, input valid);
endinterface
module adapter #(parameter int AW = 8) (bus_if bif, output logic o);
  assign o = pre_decode(bif.address);
  function automatic logic pre_decode(logic [AW-1:0] address);
    return address == '0;
  endfunction
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter #(.AW(8)) u (.bif(b.slave), .o(o));
endmodule
