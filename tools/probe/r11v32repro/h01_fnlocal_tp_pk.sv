module ch #(parameter type T = logic [7:0]) (output logic s);
  function automatic logic f();
    T [1:0] loc; loc = 0; return |loc;
  endfunction
  assign s = f();
endmodule
module top; logic s; ch i0(.s(s)); endmodule
