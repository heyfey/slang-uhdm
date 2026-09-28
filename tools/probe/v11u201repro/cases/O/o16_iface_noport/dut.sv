// § opCtxBindableTarget201v
interface bus_if;
  logic [3:0] a;
  logic [3:0] d;
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign d = f(a) + 4'd1;
endinterface
module top(output logic [3:0] o);
  bus_if b();
  assign o = b.d;
endmodule
