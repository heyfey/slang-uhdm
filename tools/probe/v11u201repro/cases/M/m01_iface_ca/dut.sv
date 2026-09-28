// § methodArgNestedRefChain201
interface bus_if;
  logic [7:0] d;
  function automatic logic [7:0] f(input logic [7:0] v); return v + d; endfunction
endinterface
module top(input logic [7:0] a [4], input logic [1:0] i, output logic [7:0] y1, output logic [7:0] y2);
  bus_if b();
  assign y1 = b.f(a[i] + 8'd1);
  always_comb y2 = b.f(a[i+1]);
endmodule
