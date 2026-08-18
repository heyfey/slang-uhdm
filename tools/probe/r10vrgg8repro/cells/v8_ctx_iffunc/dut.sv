interface bus_t;
  logic [7:0] address;
  function automatic logic pre(logic [7:0] x);
    return '1;
  endfunction
  modport slave (input address, import pre);
endinterface
module m (bus_t.slave bus_if, output logic o);
  assign o = bus_if.pre(bus_if.address);
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t bif();
  assign bif.address = a;
  m u0(.bus_if(bif), .o(o));
endmodule
