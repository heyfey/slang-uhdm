// v5 — CLASS type parameters chained.
class c #(parameter type a_t = int, parameter type b_t = a_t);
  b_t x;
  function new(); x = 0; endfunction
endclass
module dut ( output logic o );
  c #() h = new();
  assign o = 1'b0;
endmodule
