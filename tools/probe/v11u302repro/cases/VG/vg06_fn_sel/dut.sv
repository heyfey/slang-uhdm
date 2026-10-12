// § elabImpSelFlatKeepsParent302
// vg06: the package selects WSEL inside a package function and a parameter, two instances of the importer
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } w7_t;
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5};
  localparam w7_t WNON = '{a: 32'd6, b: 32'd7};
  function automatic int fa(); return WSEL.b; endfunction
  localparam int K = WSEL.a;
endpackage
module q import p7::*; #(parameter int N = 1) (output logic [31:0] o);
  assign o = fa() + K + N;
endmodule
module dut(output logic [31:0] o1, o2);
  q #(.N(1)) u1 (.o(o1));
  q #(.N(2)) u2 (.o(o2));
endmodule
