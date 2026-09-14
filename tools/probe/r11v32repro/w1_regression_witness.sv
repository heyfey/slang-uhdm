// legal SV: a `parameter type` bound to a 2-STATE vector, carrying a packed dim
module w1_child #(parameter type T = bit [7:0]) (
    output logic sink
);
  T [1:0] d;
  assign sink = |{d};
endmodule

module w1_top;
  logic sink;
  w1_child i0 (.sink(sink));
endmodule
