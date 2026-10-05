// § modportArgVarFormalTs239
// CRLF-free macro-written call (not the argument), a function with a typedef'd int formal
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
`define CALL(f, x) f(x)
module adapter (bus_if.slave bif, output logic o);
  typedef int unsigned u_t;
  assign o = `CALL(pre, bif.address);
  function automatic logic pre(u_t a);
    return a == 0;
  endfunction
endmodule
module top (output logic o);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o));
endmodule
