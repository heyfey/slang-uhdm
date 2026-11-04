// § opCtxRefArgBare201
interface bus_if; logic [3:0] d; endinterface
module top(input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  bus_if b();
  assign b.d = f(a) + 4'd1;
  logic [3:0] arr [2];
  assign arr[0] = f(a) + 4'd2;
  assign o = b.d ^ arr[0];
endmodule
