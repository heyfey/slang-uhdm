interface bus_t #(parameter int ADDRESS_WIDTH = 16);
  logic [ADDRESS_WIDTH-1:0] address;
  modport slave (input address);
endinterface
module m #(parameter int ADDRESS_WIDTH = 8, parameter bit PD = 0)
  (bus_t.slave bus_if, output logic o);
  logic inside_range;
  assign inside_range = f(bus_if.address);
  assign o = inside_range;
  function automatic logic f(
    logic [ADDRESS_WIDTH-1:0] address
  );
    if (PD) begin
      logic [ADDRESS_WIDTH-1:0] b;
      b = 8'h10;
      return (address >= b);
    end
    else begin
      return '1;
    end
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t #(.ADDRESS_WIDTH(8)) bus_if();
  assign bus_if.address = a;
  m #(.ADDRESS_WIDTH(8)) u0(.bus_if(bus_if), .o(o));
endmodule
