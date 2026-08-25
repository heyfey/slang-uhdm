// $unit wildcard import; the module has a PORT parameter of the same name, overridden.
package pv2;
  parameter int GAIN = 9;
endpackage
import pv2::*;
module leaf_v2 #(parameter int GAIN = 2) (output logic [7:0] o);
  assign o = GAIN;
endmodule
module top_v2;
  logic [7:0] w1, w2;
  leaf_v2 #(.GAIN(4)) u1 (.o(w1));
  leaf_v2           u2 (.o(w2));
endmodule
