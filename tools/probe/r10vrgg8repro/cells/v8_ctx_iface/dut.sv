interface bus_t;
  logic [7:0] address;
  modport slave (input address);
endinterface
module m (bus_t.slave bus_if, output logic o);
  function automatic logic f(logic [7:0] address);
    return '1;
  endfunction
  assign o = f(bus_if.address);
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t bif();
  assign bif.address = a;
  m u0(.bus_if(bif), .o(o));
endmodule
