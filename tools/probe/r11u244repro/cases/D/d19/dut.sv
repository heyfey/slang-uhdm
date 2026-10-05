// § methCallNameSpanAcrossLines244
interface bus_if;
  logic a;
  function automatic logic f(); return a; endfunction
endinterface
module top(output logic y);
  bus_if bus();
  assign y = bus.
             f();
endmodule
