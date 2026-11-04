// § modportArgVarFormalTs239
// named argument to a package function
interface bus_if #(parameter int AW = 16);
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  logic [AW-1:0] address;
  e_t kind;
  s_t pk;
  logic valid;
  modport slave (input address, input kind, input pk, input valid);
endinterface
package pk;
  function automatic logic pre_decode(logic [7:0] address, logic en);
    return en && address == '0;
  endfunction
endpackage
module adapter (bus_if.slave bif, output logic o);
  assign o = pk::pre_decode(.en(1'b1), .address(bif.address));
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o));
endmodule
