// § modConnIpsBaseByPort317
program pchild (input logic d);
  initial $display(d);
endprogram
module top (input logic [3:0] v, input logic [1:0] s, output logic o);
  pchild p (.d(v[s +: 1]));
  assign o = v[0];
endmodule
