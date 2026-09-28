// § sizeDimOvrFileAtDim212 — r11u217 f01: the parent overrides two size parameters of a child in ANOTHER file, one by a hex literal and one by a package localparam
package sp;
  localparam int K = 2;
endpackage
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut(input logic [3:0] a [2], output logic o);
  bi b [4] ();
  c #(.N(4'h4), .M(sp::K)) u (.p(b), .q(a), .o(o));
endmodule
