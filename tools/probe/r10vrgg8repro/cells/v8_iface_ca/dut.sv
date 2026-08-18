interface bus_t;
  logic [7:0] address;
  logic       ir;
  function automatic logic pre(logic [7:0] x);
    return '1;
  endfunction
  assign ir = pre(address);
endinterface
module m (bus_t bus_if, output logic o);
  assign o = bus_if.ir;
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t bif();
  assign bif.address = a;
  m u0(.bus_if(bif), .o(o));
endmodule
