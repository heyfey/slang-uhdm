// § modportArgOwnBodyFn239v
// a modport-imported interface function beside a same-named module function
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic valid;
  function automatic logic chk(logic [2:0] a);
    return a == 0;
  endfunction
  modport slave (input address, input valid, import chk);
endinterface
module adapter (bus_if.slave bif, output logic o, output logic o2);
  assign o = bif.chk(bif.address);
  assign o2 = valid_chk(bif.valid);
  function automatic logic chk(logic [5:0] a);
    return a == 0;
  endfunction
  function automatic logic valid_chk(logic a);
    return a;
  endfunction
endmodule
module top (output logic o, output logic o2);
  bus_if #(.AW(8)) b ();
  adapter u (.bif(b), .o(o), .o2(o2));
endmodule
