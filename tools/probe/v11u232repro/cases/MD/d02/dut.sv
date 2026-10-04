// § defAggParamBindsImportClone232
// a file-level wildcard import, a definition never instantiated, a parameter used as a dimension bound and a replication count
package p;
  typedef struct packed { logic [3:0] w; logic [3:0] d; } cfg_t;
endpackage
import p::*;
module unused #(parameter cfg_t C = '{w: 4'd2, d: 4'd3}) (output logic [C.w-1:0] o);
  assign o = '0;
endmodule
module child #(parameter cfg_t C = '{w: 4'd2, d: 4'd3}) (output logic [C.w-1:0] o, output logic [7:0] r);
  assign o = {C.w{1'b1}};
  assign r = {C.d{2'b10}};
endmodule
module top(output logic [4:0] o, output logic [7:0] r);
  child #(.C('{w: 4'd5, d: 4'd4})) c (.o(o), .r(r));
endmodule
