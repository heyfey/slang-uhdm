// § methCallNameSpanAcrossLines244
interface bus_if;
  logic [7:0] v;
  function automatic logic [7:0] get(); return v; endfunction
  task automatic put(input logic [7:0] x); v = x; endtask
endinterface
module top(input logic [7:0] d, output logic [7:0] y);
  bus_if b();
  always_comb begin
    b .put(d);
    y = b. get();
  end
endmodule
