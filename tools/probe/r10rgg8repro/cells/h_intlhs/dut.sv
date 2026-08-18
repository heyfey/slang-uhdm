interface bus_t;
  logic [7:0] address;
endinterface
module m #(parameter bit PD = 0) (bus_t bus_if, output logic o);
  logic inside_range;
  assign inside_range = f(bus_if.address);
  assign o = inside_range;
  function automatic logic f(
    logic [7:0] address
  );
    if (PD) begin
      logic [7:0] b;
      b = 8'h10;
      return (address >= b);
    end
    else begin
      return '1;
    end
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t bus_if();
  assign bus_if.address = a;
  m u0(.bus_if(bus_if), .o(o));
endmodule
