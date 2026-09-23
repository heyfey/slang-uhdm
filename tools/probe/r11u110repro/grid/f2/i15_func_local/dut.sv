module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  function automatic rt_t f(input rt_t v);
    rt_t t;
    t = v;
    return t;
  endfunction
  assign o = f(a);
endmodule
