// § modportArgVarFormalTs239
interface bus_if #(parameter int AW = 16);
  logic [AW-1:0] address;
  logic [AW-1:0] data;
  logic valid;
  modport slave (input address, input data, input valid);
  modport mon (input address, input data, input valid);
endinterface
module ad_a (bus_if.slave bif, output logic o);
  assign o = pa(bif.address);
  function automatic logic pa(logic [5:0] a);
    return a == '0;
  endfunction
endmodule
module ad_b (bus_if.mon bif, output logic o);
  assign o = pb(bif.address);
  function automatic logic pb(logic [3:0] a);
    return a == '0;
  endfunction
endmodule
module top (output logic o1, output logic o2);
  bus_if #(.AW(8)) b ();
  ad_a ua (.bif(b), .o(o1));
  ad_b ub (.bif(b), .o(o2));
endmodule
